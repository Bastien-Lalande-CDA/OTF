#Requires AutoHotkey v2.0

; ===== Test_TestsEngine.ahk =====
#Include ../src/TestsEngine.ahk
#Include ../Lib/Yunit/Yunit.ahk

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

class Test_TestsEngine {

    Test_TCP() {
        engine := FakeTestsEngine()
        result := engine.TestTCP("1.1.1.1", 80)

        Yunit.AssertEquals("Success", result)
    }

    Test_UDP() {
        engine := FakeTestsEngine()
        result := engine.TestUDP("1.1.1.1", 53)

        Yunit.AssertEquals("Sent/Open", result)
    }

    Test_ICMP() {
        engine := FakeTestsEngine()
        result := engine.TestICMP("1.1.1.1")

        Yunit.AssertEquals("Success", result)
    }
}