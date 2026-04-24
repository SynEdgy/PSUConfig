function Find-UserByCity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $city
    )

    $users = (irm -uri https://dummyjson.com/users).users.Where({$_.address.city -like ('*{0}*' -f $city)})
    return $users
}
