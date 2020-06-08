python 1_data.py Atlanta
python 1_data.py Chicago
python 1_data.py Denver
python 1_data.py Memphis

Rscript 2_create_lag_vars.r


python 3_typology.py Atlanta
python 3_typology.py Chicago
python 3_typology.py Denver
python 3_typology.py Memphis
Rscript 4_SPARCC_Maps.r

R

setwd('../')
pacman::p_load(colorout, tidyverse, data.table)

atldf <- fread("data/atlanta_typology_output.csv")
chidf <- fread("data/chicago_typology_output.csv")
dendf <- fread("data/denver_typology_output.csv")
memdf <- fread("data/memphis_typology_output.csv")

full_join(atldf %>% group_by(typ_cat) %>% summarise(atl = n()), 
chidf %>% group_by(typ_cat) %>% summarise(chi = n())) %>% 
left_join(., dendf %>% group_by(typ_cat) %>% summarise(den = n())) %>% 
left_join(., memdf %>% group_by(typ_cat) %>% summarise(mem = n()))

q()

n

# left off add density to back_407

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

4_noaffordmovers.html # similar to #7 but chicago has fewer in this one
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

7_nodensitylilossaffordlimove.html # seems fitting
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



EOG
                                    atlanta Chicago Denver  Memphis
1   no li afford                    2       20      NA      2
2   no li movers or li afford       2       20      0       2
3   no li afford, li mov, li loss   3       24      1       2     
4   no afford or li movers          7       32      4       4   
5   no afford, li mov, or li loss   8       40      5       4
6   no dense loss, li afford, li move

scen1
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     1    11     0     0
 2 ['ARE']    207   558   159    73
 3 ['ARG']     54   148    36    20
 4 ['BE']      16    81    23     1
 5 ['EOG']      2    20     0     2
 6 ['OD']      19   115    14    20
 7 ['SAE']     21   139    12    20
 8 ['SLI']    174   389   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

scen2
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     2    14     0     2
 2 ['ARE']    206   555   159    71
 3 ['ARG']     54   148    36    19
 4 ['BE']      16    81    23     1
 5 ['EOG']      3    24     1     2
 6 ['OD']      18   111    13    21
 7 ['SAE']     21   139    12    20
 8 ['SLI']    174   389   157    50
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

scen3
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

scen4
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     3    15     0     2
 2 ['ARE']    206   555   159    71
 3 ['ARG']     75   231    54    40
 4 ['BE']      16    81    23     1
 5 ['EOG']      8    40     5     4
 6 ['OD']      16    92     9    14
 7 ['SAE']     21   139    12    20
 8 ['SLI']    150   309   139    34
 9 ['SMMI']   238   515   239    41
10 []           5     5    35     5

scen5
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     5    20     5     3
 2 ['ARE']    204   550   154    70
 3 ['ARG']     69   222    54    39
 4 ['BE']      16    81    23     1
 5 ['EOG']     35    64    21     7
 6 ['OD']      16    92     9    14
 7 ['SAE']     21   139    12    20
 8 ['SLI']    129   294   123    32
 9 ['SMMI']   238   515   239    41
10 []           5     5    35     5

scen6
   typ_cat    atl   chi   den   mem
   <chr>    <int> <int> <int> <int>
 1 ['AdvG']     2    15     0     2
 2 ['ARE']    206   554   159    71
 3 ['ARG']     75   235    55    42
 4 ['BE']      16    81    23     1
 5 ['EOG']      3    27     1     2
 6 ['OD']      18   100    12    14
 7 ['SAE']     21   139    12    20
 8 ['SLI']    153   300   139    34
 9 ['SMMI']   239   516   239    41
10 []           5     5    35     5

atldf %>% filter(typ_cat == "['EOG']") %>% select(typ_cat, lmh_flag_encoded)
chidf %>% filter(typ_cat == "['EOG']") %>% select(typ_cat, lmh_flag_encoded)
dendf %>% filter(typ_cat == "['EOG']") %>% select(typ_cat, lmh_flag_encoded)
memdf %>% filter(typ_cat == "['EOG']") %>% select(typ_cat, lmh_flag_encoded)

> atldf %>% group_by(typ_cat) %>% count()
# A tibble: 10 x 2
# Groups:   typ_cat [10]
   typ_cat      n
   <chr>    <int>
 1 ['AdvG']     1
 2 ['ARE']    207
 3 ['ARG']     54
 4 ['BE']      16
 5 ['EOG']      6
 6 ['OD']      17
 7 ['SAE']     21
 8 ['SLI']    172
 9 ['SMMI']   239
10 []           5
> chidf %>% group_by(typ_cat) %>% count()
# A tibble: 10 x 2
# Groups:   typ_cat [10]
   typ_cat      n
   <chr>    <int>
 1 ['AdvG']    11
 2 ['ARE']    558
 3 ['ARG']    148
 4 ['BE']      81
 5 ['EOG']     23
 6 ['OD']     106
 7 ['SAE']    139
 8 ['SLI']    395
 9 ['SMMI']   516
10 []           5
> dendf %>% group_by(typ_cat) %>% count()
# A tibble: 9 x 2
# Groups:   typ_cat [9]
  typ_cat      n
  <chr>    <int>
1 ['ARE']    159
2 ['ARG']     36
3 ['BE']      23
4 ['EOG']      4
5 ['OD']      10
6 ['SAE']     12
7 ['SLI']    157
8 ['SMMI']   239
9 []          35
> memdf %>% group_by(typ_cat) %>% count()
# A tibble: 9 x 2
# Groups:   typ_cat [9]
  typ_cat      n
  <chr>    <int>
1 ['ARE']     73
2 ['ARG']     20
3 ['BE']       1
4 ['EOG']      2
5 ['OD']      20
6 ['SAE']     20
7 ['SLI']     50
8 ['SMMI']    41
9 []           5
> 


> atldf %>% group_by(typ_cat) %>% count()
# A tibble: 10 x 2
# Groups:   typ_cat [10]
   typ_cat      n
   <chr>    <int>
 1 ['AdvG']     1
 2 ['ARE']    207
 3 ['ARG']     54
 4 ['BE']      16
 5 ['EOG']      2
 6 ['OD']      19 #
 7 ['SAE']     21
 8 ['SLI']    174 # 
 9 ['SMMI']   239
10 []           5
> chidf %>% group_by(typ_cat) %>% count()
# A tibble: 10 x 2
# Groups:   typ_cat [10]
   typ_cat      n
   <chr>    <int>
 1 ['AdvG']    11
 2 ['ARE']    558
 3 ['ARG']    148
 4 ['BE']      81
 5 ['EOG']     14 # 
 6 ['OD']     115 # 
 7 ['SAE']    139 
 8 ['SLI']    395 
 9 ['SMMI']   516 
10 []           5
> dendf %>% group_by(typ_cat) %>% count()
# A tibble: 8 x 2
# Groups:   typ_cat [8]
  typ_cat      n
  <chr>    <int>
1 ['ARE']    159
2 ['ARG']     36
3 ['BE']      23
4 ['OD']      14 #
5 ['SAE']     12
6 ['SLI']    157
7 ['SMMI']   239
8 []          35
> memdf %>% group_by(typ_cat) %>% count()
# A tibble: 9 x 2
# Groups:   typ_cat [9]
  typ_cat      n
  <chr>    <int>
1 ['ARE']     73
2 ['ARG']     20
3 ['BE']       1
4 ['EOG']      1
5 ['OD']      21 #
6 ['SAE']     20
7 ['SLI']     50
8 ['SMMI']    41
9 []           5

https://cci-ucb.github.io/sparcc/maps/atlanta_neweog.html
https://cci-ucb.github.io/sparcc/maps/chicago_neweog.html
https://cci-ucb.github.io/sparcc/maps/denver_neweog.html
https://cci-ucb.github.io/sparcc/maps/memphis_neweog.html
