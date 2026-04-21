#Requires AutoHotkey v2.0

; ===== Test_Controller.ahk =====
#Include ../src/Controller.ahk
#Include ../Lib/Yunit/Yunit.ahk

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
    __New() {
        this.results := []
    }

    Add(result) {
        this.results.Push(result)
    }
}

class Test_Controller {

    Test_Flow() {
        controller := Controller()

        controller.parser := FakeParser()
        controller.engine := FakeEngine()
        controller.register := FakeRegister()

        controller.Run()

        Yunit.Assert(controller.register.results.Length > 0)
    }
}