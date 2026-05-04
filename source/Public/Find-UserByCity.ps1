function Find-UserByCity
{
    <#
        .SYNOPSIS
            Finds users whose address city matches the supplied value.

        .DESCRIPTION
            Queries the public https://dummyjson.com/users endpoint and returns
            the users whose 'address.city' property contains the provided
            'City' substring (case-insensitive wildcard match).

        .PARAMETER City
            The city name (or substring) to match against the user's address city.
            Matching is performed with a wildcard '*<City>*' pattern.

        .EXAMPLE
            Find-UserByCity -City 'Phoenix'

            Returns every user from the dummyjson.com sample dataset whose
            address city contains 'Phoenix'.

        .OUTPUTS
            System.Object. The user objects returned by the dummyjson.com API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $city
    )

    $users = (irm -uri https://dummyjson.com/users).users.Where({$_.address.city -like ('*{0}*' -f $city)})
    return $users
}
