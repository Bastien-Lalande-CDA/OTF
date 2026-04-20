#Requires AutoHotkey v2.0

; ===== Test_TestsEngine.ahk =====
#Include TestsFramework.ahk
#Include ../src/TestsEngine.ahk

class FakeTestsEngine extends TestsEngine {
    TestTCP(ip, port) {
        return "Success"
    }

    TestUDP(ip, port) {
        return "Sent/Open"
    }

    TestICMP(ip) {
        return "Success"
    }
}

Test_TCP() {
    engine := FakeTestsEngine()

    result := engine.TestTCP("1.1.1.1", 80)

    Assert.Equal("Success", result)
}

Test_UDP() {
    engine := FakeTestsEngine()

    result := engine.TestUDP("1.1.1.1", 53)

    Assert.Equal("Sent/Open", result)
}

RunTest("TestsEngine - TCP", Test_TCP)
RunTest("TestsEngine - UDP", Test_UDP)