#Requires AutoHotkey v2.0

; ===== RunAllTests.ahk =====
#Include ../Lib/Yunit/Yunit.ahk

#Include Test_Parser.ahk
#Include Test_TestsEngine.ahk
#Include Test_Controller.ahk
#Include Test_Register.ahk
#Include Test_HMI.ahk

Yunit.Use().Test(Test_Parser, Test_TestsEngine, Test_Controller, Test_Register, Test_HMI)