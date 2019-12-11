################################################################################
## Half Kilo PowerShell Snake
## - A PowerShell version of the classic snake game that's only 512 bytes
## - This version takes up 510 bytes - 2 bytes below the limit
################################################################################
## https://github.com/thordreier/PowerShellGames/
## https://github.com/thordreier/PowerShellGames/blob/master/HalfKiloPowerShellSnake.ps1
## https://github.com/thordreier/PowerShellGames/blob/master/HalfKiloPowerShellSnakeExplained.ps1
################################################################################
## This is free and unencumbered software released into the public domain (http://unlicense.org)
################################################################################

## This is the "big explained" version of Half Kilo PowerShell Snake
## To "build" (compact) the real version out of this file run this command
## - Remove alle lines with # (hashtag)
## - Remove all leading or traling spaces
## - All other spaces will be removed, excepct if there are doubble-spaces or ' ' (a space inside a single qoute)
## - Join all lines into one line in a file without ending linebreak
## - semicolons and doubble spaces must exist in the code where needed
# (gc HalfKiloPowerShellSnakeExplained.ps1|?{$_-notmatch'#'}|%{($_-replace'^(\s*)(.*)(\s*)$','$2')-replace"([^']) ",'$1'})-join''|Set-Content -N HalfKiloPowerShellSnake.ps1


# $u = $Host.UI.RawUi
# $q = $Host.UI.RawUi.WindowSize
# $w = $Host.UI.RawUi.WindowSize.Width - 1
$w = (
    $q = (
        $u = $Host.UI.RawUi
    ).WindowSize
).Width - 1;

# Don't show cursor
$u.CursorSize = 0;

## Create an array with hashtables representing all point in the console
## @{X=1;Y=1} -eq @{X=1;Y=1} returns false even though the values are the same so it's hard to compare
## But if we always take the same object we can compare and use -contains operator
## For example will $a[2 + 4 * $w] return @{X=2;Y=4} - and that is the same object every time, so it can be compared
$a = 0..($q.Height - 1) | %{
    $i = $_;
    0..$w | %{
        @{
            X=$_;
            Y=$i
        }
    }
};

# $d = 3                 # $d is directorion 1=left, 2=up, 3=right, 4=down (start with right)
# $y = $d                # next Y coordinate for snakes head
# $x = $y                # next X coordinate for snakes head
# $f = $a[$x]  # $f is the food, first one is 3,0
# $n = $f                # $n is the next point in the snake to draw (snakes head) 
#                        # When we start drawing the snake it is starting in 3,3 going left, so the first drawn point is 4,3
                         # but the first two points of the snake is 3,0 - though they will never be drawn
# $s = $n,$n             # $s is an array containing all points that the snake occupies. The same point is put in twice (reason is explained later)
$s = (
    $f = $n = $a[($x = $y = $d = 3)]
), $n;

## Function that will print to screen
## Eg: Z @{X=2;Y=4} 'X' - will print a X on screen position 2,4
function  Z($c, $t)
{
    $u.CursorPosition = $c;
    Write-Host  $t  -N
}

while (
    0..$w -contains $x -and
    (
        $b = $x + $y * ($w + 1)
    ) -ge 0 -and
    (
        $n = $a[$b]
    ) -and
    $s -notcontains $n
)
{

    # Print the snakes head to screen
    Z  $n  X;

    ## Millisecondens. The lower this is, the faster the snake goes
    # 99 takes up one charackter less than 100. Newer version of PowerShell allows [Double] in second, but this alwo works in PS5
    sleep  -M  99;

    while (
        # ...key presses are available int the buffer (we both get key down and key up, so we need to put it in a while)
        $u.KeyAvailable -and
        1..4 -contains (
            # ...assign virtual key code minus 36 to $k - $k must be between 1 and 4 (key kode 37 to 40 - the arrow keys)
            $k = $u.ReadKey(15).VirtualKeyCode - 36
        ) -and
        # ...don't allow a 180 turn - eg. when snake is going left, only allowed new directions are up and down
        $d % 2 -ne $k %2 
    ){
         # If all the above is true, change direction (1=left, 2=up, 3=right, 4=down)
        $d = $k
    }
    
    # Based on direction move head...
    switch ($d)
    {
        # Left
        1 {--$x}
        # Up
        2 {--$y}
        # Right
        3 {++$x}
        # Down
        4 {++$y}
    }

    # Add the new head of the snake to the snake
    $s += $n;

    # If snake head hits the food (or if food was placen inside the snake last time)
    if ($s -contains $f)
    {
        # Find new place for food
        $f = $a | random
    }
    else
    {
        # Put the snakes tail in $p and remove the tail from $s. If $s only contained two elements then $s
        # wouldn't be an array after this operation. That's why we put the same point in $s twice in the beginning
        $p, $s = $s;
        # Remove the snakes tail from screen
        Z  $p  ' '
    }

    # Print the food to screen
    Z  $f  O
}
