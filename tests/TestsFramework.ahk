#Requires AutoHotkey v2.0

; ===== TestsFramework.ahk =====

class Assert {
    static Equal(expected, actual, message := "") {
        if (expected != actual) {
            throw Error("❌ Assert Equal FAILED: " message " | Expected: " expected " Got: " actual)
        }
    }

    static True(condition, message := "") {
        if (!condition) {
            throw Error("❌ Assert True FAILED: " message)
        }
    }

    static False(condition, message := "") {
        if (condition) {
            throw Error("❌ Assert False FAILED: " message)
        }
    }
}

RunTest(name, fn) {
    try {
        fn.Call()
        MsgBox(name)
    } catch as e {
        MsgBox(name "`n" e.Message)
    }
}