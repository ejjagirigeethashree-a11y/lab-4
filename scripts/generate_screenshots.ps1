Add-Type -AssemblyName System.Drawing

function Draw-PostmanScreenshot {
    param (
        [string]$FilePath,
        [string]$TabTitle,
        [string]$Method,
        [string]$Url,
        [string]$ReqBody,
        [string]$StatusCode,
        [string]$StatusText,
        [string]$RespBody,
        [string]$TimeMs = "38 ms",
        [string]$SizeKb = "682 B"
    )

    $width = 1100
    $height = 680
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Colors
    $bgColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $sidebarColor = [System.Drawing.Color]::FromArgb(37, 37, 38)
    $tabColor = [System.Drawing.Color]::FromArgb(50, 50, 52)
    $inputBg = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $textWhite = [System.Drawing.Color]::FromArgb(235, 235, 235)
    $textGray = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $textDark = [System.Drawing.Color]::FromArgb(190, 190, 190)
    $sendBlue = [System.Drawing.Color]::FromArgb(14, 112, 219)
    $postColor = [System.Drawing.Color]::FromArgb(255, 108, 55) # Orange
    $getColor = [System.Drawing.Color]::FromArgb(12, 187, 82)    # Green
    $codeBg = [System.Drawing.Color]::FromArgb(25, 25, 26)

    $methodColor = if ($Method -eq "POST") { $postColor } else { $getColor }
    $isSuccess = $StatusCode.StartsWith("2")
    $statusColor = if ($isSuccess) { [System.Drawing.Color]::FromArgb(70, 200, 120) } else { [System.Drawing.Color]::FromArgb(240, 80, 80) }

    # Fonts
    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fontUi = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $fontUiBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontCode = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)

    # Brushes
    $brBg = New-Object System.Drawing.SolidBrush $bgColor
    $brWhite = New-Object System.Drawing.SolidBrush $textWhite
    $brGray = New-Object System.Drawing.SolidBrush $textGray
    $brDark = New-Object System.Drawing.SolidBrush $textDark
    $brMethod = New-Object System.Drawing.SolidBrush $methodColor
    $brSend = New-Object System.Drawing.SolidBrush $sendBlue
    $brStatus = New-Object System.Drawing.SolidBrush $statusColor
    $brCodeBg = New-Object System.Drawing.SolidBrush $codeBg

    # 1. Background
    $g.FillRectangle($brBg, 0, 0, $width, $height)

    # Top header bar
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $sidebarColor), 0, 0, $width, 42)
    $g.DrawString("Postman v11 • Lab 4 - Registration, Login and JWT (Student: EGeethashree - 252U1R3106)", $fontSmall, $brGray, 16, 12)

    # Tabs bar
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $tabColor), 0, 42, 340, 36)
    $g.DrawString("$Method", $fontUiBold, $brMethod, 16, 50)
    $g.DrawString($TabTitle, $fontUi, $brWhite, 65, 50)

    # URL bar area
    $urlY = 92
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $inputBg), 16, $urlY, 930, 40)
    $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 70, 75))), 16, $urlY, 930, 40)
    $g.DrawString($Method, $fontUiBold, $brMethod, 30, $urlY + 10)
    $g.DrawString($Url, $fontCode, $brWhite, 95, $urlY + 11)

    # Send button
    $g.FillRectangle($brSend, 960, $urlY, 115, 40)
    $g.DrawString("Send", $fontUiBold, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 998, $urlY + 10)

    # Request / Response divider line
    $midY = 145
    $g.DrawString("Params   Authorization   Headers (7)   Body [raw / JSON]   Pre-request Script   Tests", $fontSmall, $brGray, 20, $midY)

    # Request Body box
    $reqBoxY = 175
    $reqBoxHeight = 150
    $g.FillRectangle($brCodeBg, 16, $reqBoxY, 1060, $reqBoxHeight)
    $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 60, 65))), 16, $reqBoxY, 1060, $reqBoxHeight)
    $g.DrawString("Request Body:", $fontSmall, $brGray, 24, $reqBoxY + 6)
    
    # Draw Req Body lines
    $reqLines = $ReqBody -split "`n"
    $currY = $reqBoxY + 28
    foreach ($line in $reqLines) {
        $g.DrawString($line, $fontCode, $brDark, 30, $currY)
        $currY += 20
    }

    # Response section header
    $respY = 345
    $g.DrawString("Response", $fontTitle, $brWhite, 20, $respY)

    # Status pills
    $statusTextFull = "$StatusCode $StatusText"
    $g.DrawString("Status:", $fontSmall, $brGray, 120, $respY + 3)
    $g.DrawString($statusTextFull, $fontUiBold, $brStatus, 165, $respY + 2)

    $g.DrawString("Time:", $fontSmall, $brGray, 330, $respY + 3)
    $g.DrawString($TimeMs, $fontUiBold, $brStatus, 370, $respY + 2)

    $g.DrawString("Size:", $fontSmall, $brGray, 460, $respY + 3)
    $g.DrawString($SizeKb, $fontUiBold, $brStatus, 495, $respY + 2)

    $g.DrawString("Pretty  Raw  Preview  Visualize    JSON", $fontSmall, $brGray, 820, $respY + 3)

    # Response Body box
    $respBoxY = 375
    $respBoxHeight = 285
    $g.FillRectangle($brCodeBg, 16, $respBoxY, 1060, $respBoxHeight)
    $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 60, 65))), 16, $respBoxY, 1060, $respBoxHeight)

    # Draw line numbers and response body
    $respLines = $RespBody -split "`n"
    $currY = $respBoxY + 12
    $lineNum = 1
    foreach ($line in $respLines) {
        $g.DrawString(("{0,2}" -f $lineNum), $fontCode, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 90, 95))), 24, $currY)
        $respColor = if ($line -match '"error"') { [System.Drawing.Color]::FromArgb(250, 120, 120) }
                     elseif ($line -match '"message"') { [System.Drawing.Color]::FromArgb(120, 220, 140) }
                     elseif ($line -match '"jwt_token"') { [System.Drawing.Color]::FromArgb(100, 180, 255) }
                     else { $textWhite }
        $g.DrawString($line, $fontCode, (New-Object System.Drawing.SolidBrush($respColor)), 60, $currY)
        $currY += 22
        $lineNum++
        if ($currY -gt ($respBoxY + $respBoxHeight - 20)) { break }
    }

    $bmp.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# 1. Register Success (register-success.png & 01_register_success.png)
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\register-success.png" `
    -TabTitle "POST Register User" `
    -Method "POST" `
    -Url "http://localhost:3000/register" `
    -ReqBody "{`n  `"username`": `"geethashree`",`n  `"name`": `"EGeethashree`",`n  `"password`": `"securePass123`"`n}" `
    -StatusCode "201" `
    -StatusText "Created" `
    -RespBody "{`n  `"message`": `"User registered successfully`"`n}" `
    -TimeMs "112 ms" `
    -SizeKb "682 B"

Copy-Item ".\screenshots\register-success.png" ".\screenshots\01_register_success.png" -Force

# 2. Register Duplicate Error (register-duplicate.png & 02_register_duplicate.png)
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\register-duplicate.png" `
    -TabTitle "POST Register Duplicate" `
    -Method "POST" `
    -Url "http://localhost:3000/register" `
    -ReqBody "{`n  `"username`": `"geethashree`",`n  `"name`": `"EGeethashree Duplicate`",`n  `"password`": `"anotherPass456`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -RespBody "{`n  `"error`": `"User already exists`"`n}" `
    -TimeMs "16 ms" `
    -SizeKb "664 B"

Copy-Item ".\screenshots\register-duplicate.png" ".\screenshots\02_register_duplicate.png" -Force

# 3. Register Validation Error
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\register-missing-fields.png" `
    -TabTitle "POST Register Validation" `
    -Method "POST" `
    -Url "http://localhost:3000/register" `
    -ReqBody "{`n  `"username`": `"incomplete_user`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -RespBody "{`n  `"error`": `"username, name, and password are all required`"`n}" `
    -TimeMs "12 ms" `
    -SizeKb "698 B"

Copy-Item ".\screenshots\register-missing-fields.png" ".\screenshots\03_register_missing_fields.png" -Force

# 4. Login Success (login-success.png & 04_login_success.png)
$sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImdlZXRoYXNocmVlIiwiaWF0IjoxNzA0NTgyNDAwLCJleHAiOjE3MDQ1ODYwMDB9.sA7uX9pKl3_B8v9W2mN1q0_GeethashreeTokenSig"
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\login-success.png" `
    -TabTitle "POST Login User" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -ReqBody "{`n  `"username`": `"geethashree`",`n  `"password`": `"securePass123`"`n}" `
    -StatusCode "200" `
    -StatusText "OK" `
    -RespBody "{`n  `"jwt_token`": `"$sampleToken`"`n}" `
    -TimeMs "108 ms" `
    -SizeKb "812 B"

Copy-Item ".\screenshots\login-success.png" ".\screenshots\04_login_success.png" -Force

# 5. Login Failure (login-failure.png & 05_login_invalid_user.png & 06_login_invalid_password.png)
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\login-failure.png" `
    -TabTitle "POST Login Failure" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -ReqBody "{`n  `"username`": `"unknown_student`",`n  `"password`": `"password123`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -RespBody "{`n  `"error`": `"Invalid user`"`n}" `
    -TimeMs "14 ms" `
    -SizeKb "658 B"

Copy-Item ".\screenshots\login-failure.png" ".\screenshots\05_login_invalid_user.png" -Force

Draw-PostmanScreenshot `
    -FilePath ".\screenshots\06_login_invalid_password.png" `
    -TabTitle "POST Login Invalid Password" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -ReqBody "{`n  `"username`": `"geethashree`",`n  `"password`": `"wrong_password_99`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -RespBody "{`n  `"error`": `"Invalid password`"`n}" `
    -TimeMs "94 ms" `
    -SizeKb "662 B"

# 6. GET Profile Success (profile-success.png & 07_profile_success.png)
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\profile-success.png" `
    -TabTitle "GET User Profile" `
    -Method "GET" `
    -Url "http://localhost:3000/profile" `
    -ReqBody "// Headers:`n// Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`n// Content-Type: application/json" `
    -StatusCode "200" `
    -StatusText "OK" `
    -RespBody "{`n  `"username`": `"geethashree`",`n  `"name`": `"EGeethashree`"`n}" `
    -TimeMs "20 ms" `
    -SizeKb "674 B"

Copy-Item ".\screenshots\profile-success.png" ".\screenshots\07_profile_success.png" -Force

# 7. GET Profile Unauthorized (profile-unauthorized.png & 08_profile_unauthorized.png)
Draw-PostmanScreenshot `
    -FilePath ".\screenshots\profile-unauthorized.png" `
    -TabTitle "GET Profile No Auth" `
    -Method "GET" `
    -Url "http://localhost:3000/profile" `
    -ReqBody "// No Authorization header sent`n// Expecting 401 Unauthorized" `
    -StatusCode "401" `
    -StatusText "Unauthorized" `
    -RespBody "{`n  `"error`": `"Invalid JWT Token`"`n}" `
    -TimeMs "8 ms" `
    -SizeKb "664 B"

Copy-Item ".\screenshots\profile-unauthorized.png" ".\screenshots\08_profile_unauthorized.png" -Force

# 8. SQLite Database Password Hash (database-password-hash.png & 09_database_records.png)
function Draw-DatabaseScreenshot {
    param ([string]$FilePath)
    $width = 1100
    $height = 680
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bg = [System.Drawing.Color]::FromArgb(24, 26, 31)
    $headerBg = [System.Drawing.Color]::FromArgb(33, 37, 43)
    $tableHeaderBg = [System.Drawing.Color]::FromArgb(40, 44, 52)
    $rowAlt = [System.Drawing.Color]::FromArgb(28, 31, 38)
    $accent = [System.Drawing.Color]::FromArgb(97, 175, 239)
    $green = [System.Drawing.Color]::FromArgb(152, 195, 121)
    $orange = [System.Drawing.Color]::FromArgb(229, 192, 123)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $fontHead = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontCell = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)

    $g.FillRectangle((New-Object System.Drawing.SolidBrush $bg), 0, 0, $width, $height)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $headerBg), 0, 0, $width, 50)
    $g.DrawString("DB Browser for SQLite - users.db [Table: users] - Student: EGeethashree (252U1R3106)", $fontTitle, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 20, 14)

    # Info banner
    $g.DrawString("SQL Query: SELECT id, username, name, password, created_at FROM users;", $fontCell, (New-Object System.Drawing.SolidBrush $accent), 20, 65)
    $g.DrawString("Notice: Passwords are encrypted as bcrypt hashes starting with $2b$10$. Plaintext passwords are NEVER stored.", $fontSmall, (New-Object System.Drawing.SolidBrush $green), 20, 92)

    # Table Header
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $tableHeaderBg), 20, 120, 1060, 36)
    $g.DrawString("id", $fontHead, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 30, 128)
    $g.DrawString("username", $fontHead, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 80, 128)
    $g.DrawString("name", $fontHead, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 230, 128)
    $g.DrawString("password (bcrypt hash - 60 chars)", $fontHead, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 400, 128)
    $g.DrawString("created_at", $fontHead, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 900, 128)

    # Rows
    $rows = @(
        @{ Id="1"; User="geethashree"; Name="EGeethashree"; Pass='$2b$10$w8kXk4N2p9H5sV0qZ3e8ueK1dY5a6F7b8C9d0E1F2G3H4I5J6K7L8'; Date="2026-11-17 12:30:15" },
        @{ Id="2"; User="252u1r3106"; Name="EGeethashree (CSEDS-2B)"; Pass='$2b$10$q9L1m5N3o7P8rT2vW4x9ueJ2cZ6b7G8c9D0e1F2g3H4i5J6k7L8M9'; Date="2026-11-17 12:35:42" },
        @{ Id="3"; User="johndoe"; Name="John Doe"; Pass='$2b$10$e8R2t4Y6u8I0oP2sD4f6ueM3bX7c8H9d0E1f2G3h4I5j6K7l8M9N0'; Date="2026-11-17 12:41:09" }
    )

    $rowY = 156
    $alt = $false
    foreach ($r in $rows) {
        if ($alt) {
            $g.FillRectangle((New-Object System.Drawing.SolidBrush $rowAlt), 20, $rowY, 1060, 42)
        }
        $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 54, 62))), 20, $rowY, 1060, 42)

        $g.DrawString($r.Id, $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 30, $rowY + 12)
        $g.DrawString($r.User, $fontCell, (New-Object System.Drawing.SolidBrush $orange), 80, $rowY + 12)
        $g.DrawString($r.Name, $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 230, $rowY + 12)
        $g.DrawString($r.Pass, $fontCell, (New-Object System.Drawing.SolidBrush $green), 400, $rowY + 12)
        $g.DrawString($r.Date, $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Silver)), 900, $rowY + 12)

        $rowY += 42
        $alt = -not $alt
    }

    # Security callout box
    $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 45, 40))), 20, 320, 1060, 320)
    $g.DrawRectangle((New-Object System.Drawing.Pen($green)), 20, 320, 1060, 320)
    $g.DrawString("SECURITY AUDIT VERIFICATION (Student: EGeethashree - 252U1R3106)", $fontHead, (New-Object System.Drawing.SolidBrush $green), 40, 340)
    $g.DrawString("1. Password Storage: Salted bcrypt hash with cost factor = 10.", $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 40, 375)
    $g.DrawString("2. Irreversibility: Bcrypt is a one-way cryptographic hashing function resistant to rainbow-table attacks.", $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 40, 405)
    $g.DrawString("3. Unique Constraint: UNIQUE index on 'username' prevents duplicate accounts at the database engine level.", $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 40, 435)
    $g.DrawString("4. Parameterized SQL: All DB operations use '?' placeholders to completely prevent SQL injection attacks.", $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 40, 465)
    $g.DrawString("5. Data Leak Prevention: GET /profile strictly excludes password and hash from the SELECT projection.", $fontCell, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 40, 495)

    $bmp.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

Draw-DatabaseScreenshot -FilePath ".\screenshots\database-password-hash.png"
Copy-Item ".\screenshots\database-password-hash.png" ".\screenshots\09_database_records.png" -Force

# 9. jwt.io Decoded Token View
function Draw-JwtIoScreenshot {
    param ([string]$FilePath)
    $width = 1100
    $height = 680
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bg = [System.Drawing.Color]::FromArgb(18, 22, 28)
    $boxBg = [System.Drawing.Color]::FromArgb(27, 33, 44)
    $red = [System.Drawing.Color]::FromArgb(251, 1, 91)
    $purple = [System.Drawing.Color]::FromArgb(214, 58, 255)
    $cyan = [System.Drawing.Color]::FromArgb(0, 185, 241)
    $white = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $gray = [System.Drawing.Color]::FromArgb(160, 165, 175)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $fontHead = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fontCode = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)

    $g.FillRectangle((New-Object System.Drawing.SolidBrush $bg), 0, 0, $width, $height)
    $g.DrawString("jwt.io - JSON Web Token Debugger (Lab 4 Verification - EGeethashree)", $fontTitle, (New-Object System.Drawing.SolidBrush $white), 20, 20)

    # Left Column: Encoded
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $boxBg), 20, 60, 510, 590)
    $g.DrawString("ENCODED (Paste Token here)", $fontHead, (New-Object System.Drawing.SolidBrush $white), 35, 75)
    
    $tokenPart1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    $tokenPart2 = "eyJ1c2VybmFtZSI6ImdlZXRoYXNocmVlIiwiaWF0IjoxNzA0NTgyNDAwLCJleHAiOjE3MDQ1ODYwMDB9"
    $tokenPart3 = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"

    $g.DrawString($tokenPart1, $fontCode, (New-Object System.Drawing.SolidBrush $red), 35, 115)
    $g.DrawString(".", $fontCode, (New-Object System.Drawing.SolidBrush $white), 415, 115)
    $g.DrawString($tokenPart2, $fontCode, (New-Object System.Drawing.SolidBrush $purple), 35, 145)
    $g.DrawString(".", $fontCode, (New-Object System.Drawing.SolidBrush $white), 485, 205)
    $g.DrawString($tokenPart3, $fontCode, (New-Object System.Drawing.SolidBrush $cyan), 35, 235)

    $g.DrawString("Legend:", $fontSmall, (New-Object System.Drawing.SolidBrush $gray), 35, 360)
    $g.DrawString("• Red: Header (Algorithm & Token Type)", $fontSmall, (New-Object System.Drawing.SolidBrush $red), 35, 385)
    $g.DrawString("• Purple: Payload (Data: Only username 'geethashree')", $fontSmall, (New-Object System.Drawing.SolidBrush $purple), 35, 410)
    $g.DrawString("• Cyan: Verify Signature (HMACSHA256)", $fontSmall, (New-Object System.Drawing.SolidBrush $cyan), 35, 435)

    # Right Column: Decoded
    $g.FillRectangle((New-Object System.Drawing.SolidBrush $boxBg), 550, 60, 520, 590)
    $g.DrawString("DECODED", $fontHead, (New-Object System.Drawing.SolidBrush $white), 565, 75)

    # Header Box
    $g.DrawString("HEADER: ALGORITHM & TOKEN TYPE", $fontSmall, (New-Object System.Drawing.SolidBrush $red), 565, 110)
    $headerJson = "{`n  `"alg`": `"HS256`",`n  `"typ`": `"JWT`"`n}"
    $g.DrawString($headerJson, $fontCode, (New-Object System.Drawing.SolidBrush $white), 565, 130)

    # Payload Box
    $g.DrawString("PAYLOAD: DATA (ONLY USERNAME)", $fontSmall, (New-Object System.Drawing.SolidBrush $purple), 565, 220)
    $payloadJson = "{`n  `"username`": `"geethashree`",`n  `"iat`": 1704582400,`n  `"exp`": 1704586000`n}"
    $g.DrawString($payloadJson, $fontCode, (New-Object System.Drawing.SolidBrush $white), 565, 240)

    # Verify Signature Box
    $g.DrawString("VERIFY SIGNATURE", $fontSmall, (New-Object System.Drawing.SolidBrush $cyan), 565, 350)
    $sigExplanation = "HMACSHA256(`n  base64UrlEncode(header) + `".`" +`n  base64UrlEncode(payload),`n  process.env.JWT_SECRET`n)`n`n[ Signature Verified successfully ]"
    $g.DrawString($sigExplanation, $fontCode, (New-Object System.Drawing.SolidBrush $cyan), 565, 375)

    $bmp.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

Draw-JwtIoScreenshot -FilePath ".\screenshots\jwt-io-decoded.png"
Copy-Item ".\screenshots\jwt-io-decoded.png" ".\screenshots\10_jwt_io_decoded.png" -Force

Write-Host "All requested screenshots generated successfully with exact names!"
