#Requires AutoHotkey v2.0

; ===== Test_Controller.ahk =====
#Include ../src/Controller.ahk
#Include TestsFramework.ahk

class FakeParser {
    Parse() {
        return [
            {source_ip: "127.0.0.1", destination_ip: "1.1.1.1", protocol: "TCP", designation_port: 80}
        ]
    }
}

class FakeEngine {
    RunTest(row) {
        return "Success"
    }
}

class FakeRegister {
    results := []

    Add(result) {
        this.results.Push(result)
    }
}

Test_Controller_Flow() {
    controller := Controller()

    controller.parser := FakeParser()
    controller.engine := FakeEngine()
    controller.register := FakeRegister()

    controller.Run()

    Assert.True(controller.register.results.Length > 0)
}

RunTest("Controller - orchestration", Test_Controller_Flow)