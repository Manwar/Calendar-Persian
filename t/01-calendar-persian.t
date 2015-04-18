
use 5.006;
use Test::More tests => 2;
use strict; use warnings;
use Calendar::Persian;

eval { Calendar::Persian->new({ year => -1390, month => 1 }); };
like($@, qr/ERROR: Invalid year \[\-1390\]./);

eval { Calendar::Persian->new({ year => 1390, month => 13 }); };
like($@, qr/ERROR: Invalid month \[13\]./);
