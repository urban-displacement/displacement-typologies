# Map variations

These changes mostly affect EOG but also have slight effects on AdvG and ARG. 

scenario 1 = no li afford  
scenario 2 = no li movers or li afford  
scenario 3 = no li afford, li mov, li loss  
scenario 4 = no afford or li movers  
scenario 5 = no afford, li mov, or li loss  
scenario 6 = no density li loss, li afford, li move  
scenerio 7 = no density li loss, afford, li mov  

## Scenerio counts

```
0_base.html
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     1    11    NA    NA
 2 ['ARE']    207   558   159    73
 3 ['ARG']     54   148    36    20
 4 ['BE']      16    81    23     1
 5 ['EOG']      6    23     4     2
 6 ['OD']      17   106    10    20
 7 ['SAE']     21   139    12    20
 8 ['SLI']    172   395   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

1_noliafford.html
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     1    11    NA    NA
 2 ['ARE']    207   558   159    73
 3 ['ARG']     54   148    36    20
 4 ['BE']      16    81    23     1
 5 ['EOG']      2    14    NA     1
 6 ['OD']      19   115    14    21
 7 ['SAE']     21   139    12    20
 8 ['SLI']    174   395   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

2_noliaffordmovers.html
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     2    14    NA     2
 2 ['ARE']    206   555   159    71
 3 ['ARG']     54   148    36    19
 4 ['BE']      16    81    23     1
 5 ['EOG']      3    24     1     2
 6 ['OD']      18   111    13    21
 7 ['SAE']     21   139    12    20
 8 ['SLI']    174   389   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

3_noliaffordmoversloss.html
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     4    19     5     3
 2 ['ARE']    204   550   154    70
 3 ['ARG']     51   148    36    18
 4 ['BE']      16    81    23     1
 5 ['EOG']     19    39    10     4
 6 ['OD']      18   111    13    21
 7 ['SAE']     21   139    12    20
 8 ['SLI']    161   374   148    49
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

4_noaffordmovers.html  
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     2    14    NA     2
 2 ['ARE']    206   555   159    71
 3 ['ARG']     54   148    36    19
 4 ['BE']      16    81    23     1
 5 ['EOG']      8    40     5     4
 6 ['OD']      16    97     9    19
 7 ['SAE']     21   139    12    20
 8 ['SLI']    171   387   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

5_noaffordmoversloss.html
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     4    19     5     3
 2 ['ARE']    204   550   154    70
 3 ['ARG']     51   148    36    18
 4 ['BE']      16    81    23     1
 5 ['EOG']     35    64    21     7
 6 ['OD']      16    97     9    19
 7 ['SAE']     21   139    12    20
 8 ['SLI']    147   363   141    48
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

6_nodensitylossliaffordlimove.html
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     2    15    NA     2
 2 ['ARE']    206   554   159    71
 3 ['ARG']     54   148    36    19
 4 ['BE']      16    81    23     1
 5 ['EOG']      3    37     1     2
 6 ['OD']      18   111    13    21
 7 ['SAE']     21   139    12    20
 8 ['SLI']    174   376   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

7_nodensitylilossaffordlimove.html 
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     2    15    NA     2
 2 ['ARE']    206   554   159    71
 3 ['ARG']     54   148    36    19
 4 ['BE']      16    81    23     1
 5 ['EOG']      8    58     5     4
 6 ['OD']      16    97     9    19
 7 ['SAE']     21   139    12    20
 8 ['SLI']    171   369   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

```

# Maps

## Atlanta

http://cci-ucb.github.io/sparcc/maps/atlanta_0_base.html  
http://cci-ucb.github.io/sparcc/maps/atlanta_1_noliafford.html  
http://cci-ucb.github.io/sparcc/maps/atlanta_2_noliaffordmovers.html    
http://cci-ucb.github.io/sparcc/maps/atlanta_3_noliaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/atlanta_4_noaffordmovers.html # 4 and 7 seem to be the same  
http://cci-ucb.github.io/sparcc/maps/atlanta_5_noaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/atlanta_6_nodensitylossliaffordlimove.html  
http://cci-ucb.github.io/sparcc/maps/atlanta_7_nodensitylilossaffordlimove.html  

## Chicago

http://cci-ucb.github.io/sparcc/maps/chicago_0_base.html  
http://cci-ucb.github.io/sparcc/maps/chicago_1_noliafford.html  
http://cci-ucb.github.io/sparcc/maps/chicago_2_noliaffordmovers.html  
http://cci-ucb.github.io/sparcc/maps/chicago_3_noliaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/chicago_4_noaffordmovers.html  
http://cci-ucb.github.io/sparcc/maps/chicago_5_noaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/chicago_6_nodensitylossliaffordlimove.html  
http://cci-ucb.github.io/sparcc/maps/chicago_7_nodensitylilossaffordlimove.html  

## Denver

http://cci-ucb.github.io/sparcc/maps/denver_0_base.html  
http://cci-ucb.github.io/sparcc/maps/denver_1_noliafford.html  
http://cci-ucb.github.io/sparcc/maps/denver_2_noliaffordmovers.html  
http://cci-ucb.github.io/sparcc/maps/denver_3_noliaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/denver_4_noaffordmovers.html  
http://cci-ucb.github.io/sparcc/maps/denver_5_noaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/denver_6_nodensitylossliaffordlimove.html  
http://cci-ucb.github.io/sparcc/maps/denver_7_nodensitylilossaffordlimove.html  

## Memphis

http://cci-ucb.github.io/sparcc/maps/memphis_0_base.html  
http://cci-ucb.github.io/sparcc/maps/memphis_1_noliafford.html  
http://cci-ucb.github.io/sparcc/maps/memphis_2_noliaffordmovers.html  
http://cci-ucb.github.io/sparcc/maps/memphis_3_noliaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/memphis_4_noaffordmovers.html  
http://cci-ucb.github.io/sparcc/maps/memphis_5_noaffordmoversloss.html  
http://cci-ucb.github.io/sparcc/maps/memphis_6_nodensitylossliaffordlimove.html  
http://cci-ucb.github.io/sparcc/maps/memphis_7_nodensitylilossaffordlimove.html  

