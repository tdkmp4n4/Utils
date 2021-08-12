function Get-AdGroupForeignMembers
{
    param(
        [string]$DomainFQDN
    )

    . .\PowerView_dev.ps1
    $ForeignUsers = Get-DomainObject -Properties objectsid,distinguishedname -SearchBase "GC://$DomainFQDN" -LDAPFilter '(objectclass=foreignSecurityPrincipal)' | ? {$_.objectsid -match '^S-1-5-.*-[1-9]\d{2,}$'} | Select-Object -ExpandProperty distinguishedname
    $Domains = @{}
 
    $ForeignMemberships = ForEach($ForeignUser in $ForeignUsers) {
    $ForeignUserDomain = $ForeignUser.SubString($ForeignUser.IndexOf('DC=')) -replace 'DC=','' -replace ',','.'
    if (-not $Domains[$ForeignUserDomain]) {
        $Domains[$ForeignUserDomain] = $True
            Get-DomainGroup -Domain $ForeignUserDomain -Scope DomainLocal -LDAPFilter '(member=*)' -Properties distinguishedname,member | ForEach-Object {
                if ($($_.member | Where-Object {$ForeignUsers  -contains $_})) {
                    $_
                }
            }
        }
    }
 
    $ForeignMemberships | Format-List

}