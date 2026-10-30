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
    [APIEndpoint(
        Name = 'findUserByCity',
        Path = '/users/by-city',
        Description = 'Find DummyJSON users whose address city contains the supplied value.',
        Method = 'GET',
        Authentication = $false,
        Role = ('admin','user'),
        Tag = 'Users',
        Timeout = 30
    )]
    [AiTool(
        Description = 'Finds users by city'
    )]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $City
    )

    $invokeRestMethodParameters = @{
        Uri = 'https://dummyjson.com/users'
    }
    $cityPattern = '*{0}*' -f $City
    $users = (Invoke-RestMethod @invokeRestMethodParameters).users.Where(
        { $_.address.city -like $cityPattern }
    )

    $users
}
