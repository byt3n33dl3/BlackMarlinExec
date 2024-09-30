@{
    psModuleExtensions  =   @(
        '.psm1'
        '.xaml'
        '.cdxml'
        '.dll'
    )

    psDirsShouldPresent =   @(
        #'Functions'
        'Functions\Private'
        'Functions\Public'
    )

    psScriptAnalyzerRules   =   @{
        Severity    =   'Error'
        #Severity    =   'Information'
        #Severity    =   'ParseError'
        #Severity    =   'Warning'
        IncludeRule =   @()
        ExcludeRule =   @(
            #'PSAvoidTrailingWhitespace'
            #'PSReviewUnusedParameter'
        )

        Manifest            =   @{
            Severity    = 'Warning'
            IncludeRule =   @()
            ExcludeRule =   @(
                #'PSUseToExportFieldsInManifest'
            )
        }

        PrivateFunctions    =   @{
            Severity    =   'Error'
            #Severity    =   'Information'
            #Severity    =   'ParseError'
            #Severity    =   'Warning'
            IncludeRule =   @()
            ExcludeRule =   @(
                #'PSAvoidTrailingWhitespace'
                #'PSReviewUnusedParameter'
                #'PSUseApprovedVerbs'
                #'PSUseSingularNouns'
            )
        }

        PublicFunctions    =   @{
            Severity    =   'Error'
            #Severity    =   'Information'
            #Severity    =   'ParseError'
            #Severity    =   'Warning'
            IncludeRule =   @()
            ExcludeRule =   @(
                #'PSReviewUnusedParameter'
            )
        }
    }
}
