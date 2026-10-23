@{
    light = @{
        palette = @{
            type       = 'light'
            primary    = @{
                light = '#63A8E4'
                main  = '#2167AE'
                dark  = '#172A46'
            }
            secondary  = @{
                light = '#72D6FF'
                main  = '#38A7DF'
                dark  = '#1777A8'
            }
            background = @{
                default = '#F6F9FC'
                paper   = '#FFFFFF'
            }
            text       = @{
                primary   = '#172A46'
                secondary = '#5C6F86'
            }
            error      = @{ main = '#D64550' }
            warning    = @{ main = '#E89A2D' }
            success    = @{ main = '#218A67' }
        }
        typography = @{
            fontFamily        = "'Segoe UI', Inter, sans-serif"
            fontSize          = 14
            fontWeightRegular = 400
            fontWeightMedium  = 700
            h2                = @{
                fontWeight    = 850
                letterSpacing = '-0.045em'
            }
            h3                = @{
                fontWeight    = 850
                letterSpacing = '-0.035em'
            }
            h4                = @{
                fontWeight    = 800
                letterSpacing = '-0.025em'
            }
            h5                = @{ fontWeight = 700 }
        }
        shape      = @{ borderRadius = 10 }
        overrides  = @{
            MuiAppBar = @{
                colorPrimary = @{
                    backgroundColor = '#FFFFFF'
                    color           = '#172A46'
                }
            }
            MuiButton = @{
                root = @{
                    borderRadius  = 10
                    fontWeight    = 700
                    textTransform = 'none'
                }
            }
            MuiDrawer = @{
                paper = @{
                    backgroundColor = '#FFFFFF'
                    borderRight     = '1px solid #DCE6F1'
                }
            }
            MuiListItemButton = @{
                root = @{
                    '&.Mui-selected' = @{ color = '#38A7DF' }
                }
            }
            MuiListItemIcon = @{
                root = @{
                    color    = '#38A7DF'
                    minWidth = 40
                }
            }
            MuiPaper = @{
                rounded = @{ borderRadius = 18 }
            }
            MuiTypography = @{
                h2    = @{ color = '#172A46' }
                h3    = @{ color = '#172A46' }
                h4    = @{ color = '#172A46' }
                h5    = @{ color = '#172A46' }
                h6    = @{ color = '#172A46' }
            }
        }
    }
    dark  = @{
        palette = @{
            type       = 'dark'
            primary    = @{
                light = '#72D6FF'
                main  = '#38A7DF'
                dark  = '#2167AE'
            }
            secondary  = @{
                light = '#63A8E4'
                main  = '#2167AE'
                dark  = '#172A46'
            }
            background = @{
                default = '#08091F'
                paper   = '#12162D'
            }
            text       = @{
                primary   = '#F4F8FF'
                secondary = '#B7CCE3'
            }
            error      = @{ main = '#E56B73' }
            warning    = @{ main = '#F0B45A' }
            success    = @{ main = '#54B991' }
        }
        typography = @{
            fontFamily        = "'Segoe UI', Inter, sans-serif"
            fontSize          = 14
            fontWeightRegular = 400
            fontWeightMedium  = 700
            h2                = @{
                fontWeight    = 850
                letterSpacing = '-0.045em'
            }
            h3                = @{
                fontWeight    = 850
                letterSpacing = '-0.035em'
            }
            h4                = @{
                fontWeight    = 800
                letterSpacing = '-0.025em'
            }
            h5                = @{ fontWeight = 700 }
        }
        shape      = @{ borderRadius = 10 }
        overrides  = @{
            MuiAppBar = @{
                colorPrimary = @{
                    backgroundColor = '#12162D'
                    color           = '#F4F8FF'
                }
            }
            MuiButton = @{
                root = @{
                    borderRadius  = 10
                    fontWeight    = 700
                    textTransform = 'none'
                }
            }
            MuiDrawer = @{
                paper = @{
                    backgroundColor = '#12162D'
                    borderRight     = '1px solid #293452'
                }
            }
            MuiListItemButton = @{
                root = @{
                    '&.Mui-selected' = @{ color = '#38A7DF' }
                }
            }
            MuiListItemIcon = @{
                root = @{
                    color    = '#38A7DF'
                    minWidth = 40
                }
            }
            MuiPaper = @{
                rounded = @{ borderRadius = 18 }
            }
            MuiTypography = @{
                h2    = @{ color = '#F4F8FF' }
                h3    = @{ color = '#F4F8FF' }
                h4    = @{ color = '#F4F8FF' }
                h5    = @{ color = '#F4F8FF' }
                h6    = @{ color = '#F4F8FF' }
            }
        }
    }
}
