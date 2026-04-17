#Requires AutoHotkey v2.0

desordered_rows := [
    ["source_name1","source_ip1","destination_name1","destination_ip1","designation_port1","protocol1","service_name1","Succès"],
    ["source_name2","source_ip2","destination_name2","destination_ip2","designation_port2","protocol2","service_name2","Échec"],
    ["source_name3","source_ip3","destination_name3","destination_ip3","designation_port3","protocol3","service_name3","Succès"],
    ["source_name4","source_ip4","destination_name4","destination_ip4","designation_port4","protocol4","service_name4","Échec"]
]

SortArray(desordered_rows, CompareStatus)

CompareStatus(a, b) {
    order := Map("Succès", 1, "Échec", 2, "Échec", 2, "Échec", 2)
    return order[a[8]] - order[b[8]]
}

SortArray(arr, cmp) {
    len := arr.Length
    Loop len - 1 {
        i := A_Index
        Loop len - i {
            j := A_Index
            if (cmp(arr[j], arr[j+1]) > 0) {
                temp := arr[j]
                arr[j] := arr[j+1]
                arr[j+1] := temp
            }
        }
    }
}