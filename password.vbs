Dim password, encryptedPass, decodedPass, newPassword, newEncodedPass, mode, changePassword
mode = WScript.Arguments.Count

' Encrypted password (Base64 encoded for "MySecret123")
encryptedPass = "TXlTZWNyZXQxMjM="

' Decode the Base64 password
decodedPass = Trim(DecodeBase64(encryptedPass))

If mode = 0 Then
    ' Normal Unlocking Mode
    password = Trim(RemoveExtraChars(GetHiddenPassword("Enter password to unlock:")))

    If password = decodedPass Then
        ' If the password is correct, ask if the user wants to change it
        changePassword = MsgBox("Password is correct! Do you want to change the password?", vbYesNo, "Change Password")

        If changePassword = vbYes Then
            ' Proceed to password change
            newPassword = Trim(RemoveExtraChars(GetHiddenPassword("Enter new password:")))
            If newPassword = "" Then
                MsgBox "Password cannot be empty!", vbExclamation, "Error"
                WScript.Quit(1)
            End If
            ' Encode and save the new password
            newEncodedPass = EncodeBase64(newPassword)
            encryptedPass = newEncodedPass  ' Update the encrypted password
            MsgBox "Password changed successfully!", vbInformation, "Success"
        End If
        WScript.Quit(0)  ' Success
    Else
        MsgBox "Incorrect password!", vbCritical, "Access Denied"
        WScript.Quit(1)  ' Failure
    End If
Else
    ' Password Change Mode (if the user selects the option)
    password = Trim(RemoveExtraChars(GetHiddenPassword("Enter current password to change:", "Change Password")))

    If password <> decodedPass Then
        MsgBox "Incorrect password! Cannot change password.", vbCritical, "Error"
        WScript.Quit(1)
    End If
    
    ' New password input
    newPassword = Trim(RemoveExtraChars(GetHiddenPassword("Enter new password:", "Change Password")))
    If newPassword = "" Then
        MsgBox "Password cannot be empty!", vbExclamation, "Error"
        WScript.Quit(1)
    End If

    ' Encode the new password
    newEncodedPass = EncodeBase64(newPassword)
    
    ' Save new password (in a real system, it should be written to a secure file)
    encryptedPass = newEncodedPass  ' Update the encrypted password
    MsgBox "Password changed successfully!", vbInformation, "Success"
    WScript.Quit(0)
End If

' Function to get password securely (Using PowerShell)
Function GetHiddenPassword(promptText)
    Dim shell, command, password
    Set shell = CreateObject("WScript.Shell")
    command = "powershell -Command ""$pword = Read-Host '" & promptText & "' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword))"""
    password = shell.Exec(command).StdOut.ReadAll()
    GetHiddenPassword = Trim(password)
    Set shell = Nothing
End Function

' Function to remove extra characters (newline, carriage return)
Function RemoveExtraChars(str)
    str = Replace(str, vbCrLf, "")  ' Remove carriage return & linefeed
    str = Replace(str, vbLf, "")    ' Remove linefeed
    str = Replace(str, vbCr, "")    ' Remove carriage return
    RemoveExtraChars = Trim(str)
End Function

' Function to decode Base64
Function DecodeBase64(str)
    Dim objXML, objNode, binaryData
    Set objXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set objNode = objXML.createElement("base64")
    objNode.DataType = "bin.base64"
    objNode.Text = str
    binaryData = objNode.nodeTypedValue
    DecodeBase64 = BinaryToString(binaryData)
    Set objNode = Nothing
    Set objXML = Nothing
End Function

' Function to encode Base64 (for saving new password)
Function EncodeBase64(str)
    Dim objXML, objNode
    Set objXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set objNode = objXML.createElement("base64")
    objNode.DataType = "bin.base64"

    ' Convert password to byte array and encode to Base64
    objNode.nodeTypedValue = StrConv(str, vbFromUnicode)  ' Convert to byte array
    EncodeBase64 = objNode.Text
    Set objNode = Nothing
    Set objXML = Nothing
End Function

' Function to convert binary data to string
Function BinaryToString(binaryData)
    Dim i, result
    result = ""
    For i = 1 To LenB(binaryData)
        result = result & Chr(AscB(MidB(binaryData, i, 1)))
    Next
    BinaryToString = result
End Function
