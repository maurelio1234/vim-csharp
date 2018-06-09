" Vim plugin functions
" Language:     Microsoft C#
" Maintainer:   Kian Ryan (kian@orangetentacle.co.uk)
" Last Change:  2015 Apr 22

function! s:get_net_framework_dir(version)

    if exists("g:net_framework_top")
        net_framework_top = g:net_framework_top
    elseif str2nr(a:version) >= 12
        let net_framework_top = "c:\\progra~2\\MSBuild\\"
    else
        let net_framework_top = "c:\\windows\\Microsoft.NET\\Framework\\"
    endif

    if a:version == "1"
        return net_framework_top . "v1.1.4322\\"
    elseif a:version == "2"
        return net_framework_top . "v2.0.50727\\"
    elseif a:version == "3.5"
        return net_framework_top . "v3.5\\"
    elseif a:version == "4"
        return net_framework_top . "v4.0.30319\\"
    elseif a:version == "12"
        return net_framework_top . "12.0\\Bin\\"
    elseif a:version == "14"
        return net_framework_top . "14.0\\Bin\\"
    endif

endfunction

function! cs#get_net_compiler(compiler)

    if exists("g:net_framework_version")
        let msbuild = s:get_net_framework_dir(g:net_framework_version) . a:compiler
        return msbuild
    else
        if executable(a:compiler)
            let msbuild = a:compiler
            return msbuild
        else
            for i in ["14","12","4","3.5","2","1"]
                let msbuild = s:get_net_framework_dir(i) . a:compiler . ".exe"
                if findfile(msbuild) != ""
                    return msbuild
                endif
            endfor
        endif

        " Hail mary test for xbuild
        if executable("xbuild")
            let msbuild = "xbuild"
            return msbuild
        endif
    endif
endfunction

function! cs#find_file(basepath, filepattern)
    let current_dir = a:basepath
    let i = 0
    while i <= 10
        " echo "Looking for file on pattern " . a:filepattern . " file at " . current_dir

        let solutions = globpath(current_dir, a:filepattern, 0, 1)

        if len(solutions) > 0
            " echo "Found " . solutions[0]
            return solutions[0]
        endif

        let i = i + 1
        let current_dir = current_dir . '//..'
    endwhile

    " echo "Not found"
    return ""
endfunction

function! cs#find_net_solution_file()
    let current_dir = expand("%:p:h") 

    if !exists("g:net_find_csproj")
        let g:net_find_csproj = 0
    endif

    if g:net_find_csproj
        let csproj = cs#find_file(current_dir, "*.csproj")
        if strlen(csproj) > 0
            return csproj
        endif

        let sln = cs#find_file(current_dir, "*.sln")
        if strlen(sln) > 0
            return sln
        endif
    else
        let sln = cs#find_file(current_dir, "*.sln")
        if strlen(sln) > 0
            return sln
        endif

        let csproj = cs#find_file(current_dir, "*.csproj")
        if strlen(csproj) > 0
            return csproj
        endif
    endif

    return ""
endfunction

