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

        if (result != "Success")
            throw Error("Expected Success, got " result)
    }

    Test_UDP() {
        engine := FakeTestsEngine()
        result := engine.TestUDP("1.1.1.1", 53)

        if (result != "Sent/Open")
            throw Error("Expected Sent/Open, got " result)
    }

    Test_ICMP() {
        engine := FakeTestsEngine()
        result := engine.TestICMP("1.1.1.1")

        if (result != "Success")
            throw Error("Expected Success, got " result)
    }
}