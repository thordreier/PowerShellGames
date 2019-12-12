################################################################################
## Quarter Kilo PowerShell Snake
## - A PowerShell version of the classic snake game that's only 256 bytes
## - This version takes up XXX bytes - XXX bytes below the limit
################################################################################
## Should be run i a console windows with these width/height dimensions: 120x30
## A lot of checks a disabled, so it's harder to die!
################################################################################
## https://github.com/thordreier/PowerShellGames/
## https://github.com/thordreier/PowerShellGames/blob/master/QuarterKiloPowerShellSnake.ps1
## https://github.com/thordreier/PowerShellGames/blob/master/QuarterKiloPowerShellSnakeExplained.ps1
################################################################################
## This is free and unencumbered software released into the public domain (http://unlicense.org)
################################################################################

## This is the "big explained" version of Quarter Kilo PowerShell Snake
## To "build" (compact) the real version out of this file run this command
## - Remove alle lines with # (hashtag)
## - Remove all leading or traling spaces
## - All other spaces will be removed, excepct if there are doubble-spaces or ' ' (a space inside a single qoute)
## - Join all lines into one line in a file without ending linebreak
## - semicolons and doubble spaces must exist in the code where needed
# (gc QuarterKiloPowerShellSnakeExplained.ps1|?{$_-notmatch'#'}|%{($_-replace'^(\s*)(.*)(\s*)$','$2')-replace"([^']) ",'$1'})-join''|Set-Content -N QuarterKiloPowerShellSnake.ps1


# $n is head of snake
# $f is food
$f = $n = 9;

# $s is the snake
$s = 0, 0;

# Don't allow to be negative. @(1,2,3)[-1] will return the last element in the array. We don't want that
while ($n -ge 0)
{
    
    while(
        # ...key presses are available int the buffer (we both get key down and key up, so we need to put it in a while)
        ($u = $Host.UI.RawUi).KeyAvailable -and
        # ...assign virtual key code minus 1 to $d - when using arrow keys $d will become between 36 and 39
        # Key presses other than arrow keys are still put in $d, so unexpected stuf will happen if you use other keys
        ($d = $u.ReadKey(15).VirtualKeyCode -1 )
    )
    {}

    # Output-buffer. Array of chars. We don't use the bottom line in the console, because the screen would roll if we did
    # We assume a console with dimensions 120x30: 120 * 29 = 3480
    $o = @(' ') * 3480;

    # Basically the formula is the same as
    # switch($_){36{-1} 37{-120} 38{1} 39{120}}
    # At least if you put numbers between 36 and 39 into it. We just save 12 characters this way
    # So:
    # Left:  $n = $n - 1
    # Up:    $n = $n - 120
    # Right: $n = $n + 1
    # Down:  $n = $n + 120
    # and the we add $n to the end of the array $s
    $s += $n += (($d * 2) - 75) % 2 * ( $d % 2 * 119 +1 );

    # Basically it is the same as
    # if ($f-eq$n) {$f=random 3480} else {$p,$s=$s}
    # just one character less (and without the sideeffect)
    # Sideeffect is that it outputs "True`n" to the screen, and we need that linebreak to align the ouput
    $f -eq $n -and 
    ($f = random  3480) -or
    ($p, $s = $s);

    # Place food in output-buffer
    $o[$f] = 'O';
    
    # Place snake in output-buffer
    $s | %{
        $o[$_] = 'X'
    };

    # Output to screen, just print all characters in the array
    $o -join '';

    ## Millisecondens. The lower this is, the faster the snake goes
    # 99 takes up one charackter less than 100. Newer version of PowerShell allows [Double] in second, but this alwo works in PS5
    sleep  -M  99
}
