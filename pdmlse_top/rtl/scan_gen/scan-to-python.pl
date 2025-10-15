#!/usr/bin/perl

# This script generates python cell bits mapping based on scan fields defined in a
# scan chain configuration file.

use strict;
use POSIX;

# Default Parameters
my $TwoPhase = 1;
my $ConfigLatch = 1;

if ((@ARGV != 2) && (@ARGV != 3))
{
    print   "\n";
    print   "    This script generates python cell bits mapping based on scan fields defined in a\n" .
            "    scan chain configuration file.\n\n";

    print   "        USAGE: scan-to-python.pl CFGFILE OUTPUTFILE [-append]\n\n";
    exit(1);
}

my $cfgFile = $ARGV[0];
my $outFile = $ARGV[1];
my $append = 0;
if (@ARGV == 3)
{
    ($ARGV[2] eq "-append") or die "Last argument must be '-append'!";
    $append = 1;
}

# perl mode flag for parsing
my $perlMode = 0;

my $moduleName;
my @chainConfig;
my @signals;
my %param;
open CFGFILE, "<$cfgFile" or die "Cannot open scan chain configuration file '$cfgFile'!";

my $evalCode;

# Parse each line in the scan chain configuration file
foreach(<CFGFILE>)
{
    my $line = $_;
    chomp($line);

    # begin/end perl mode
    if ($line =~ /^\s*begin:perl\s*$/)
    {
        $perlMode = 1;
        $evalCode = "";
    }
    elsif ($line =~ /^\s*end:perl\s*$/)
    {
        $perlMode = 0;
        eval $evalCode or die "Expression evaluation error: $@Eval code: \n$evalCode\n";
    }
    # if in perl mode, evaluate the line as a perl expression
    elsif ($perlMode)
    {
        $evalCode .= $line . "\n";
    }
    # Module name of the generated scan chain
    elsif ($line =~ /^\s*Name\s*=\s*(\w+)\s*$/)
    {
        $moduleName = $1;
    }
    # Config field definition (Without Mult, Old Style, EOS12 and before))
    elsif ($line =~ /^\s*([\w]+)\s+([RW]?)\s+(\S+)\s*$/)
    {
        # Evaluate the field width expression
        my $fieldWidth = eval $3 or die "Expression evaluation error:\n    $3\n";
        # Add to the list of config fields
        addField($1, $2, $fieldWidth, 1);
    }
    # Config field definition
    elsif ($line =~ /^\s*([\w]+)\s+([RW]?)\s+(\S+)\s*(\S+)\s*$/)
    {
        # Evaluate the field width expression
        my $fieldWidth = eval $3 or die "Expression evaluation error:\n    $3\n";
        my $fieldMult = eval $4 or die "Expression evaluation error:\n     $4\n";
        # Add to the list of config fields
        addField($1, $2, $fieldWidth, $fieldMult);
    }

}
close CFGFILE;

if (!$moduleName)
{
    $moduleName = 'ScanChain';
    printf("Warning: no scan chain module name given, defaulting to 'ScanChain'\n");
}

if ($append) {open OUTFILE, ">>$outFile" or die "Cannot write to output verilog file '$outFile'!";}
else {open OUTFILE, ">$outFile" or die "Cannot write to output verilog file '$outFile'!";}

writeHeader();
writeClass();
writeConstructor();
writeLength();
writeToBits();
writeFromBits();
writeCreateFromBits();
writeGetWriteBits();
writeCommentSeparator(0);

close OUTFILE;

printf("Python scan bits generated.\n");

# Subroutines
sub writeHeader()
{
    writeCommentSeparator(0);
    printf(OUTFILE "# This file was auto generated with the command:\n");
    printf(OUTFILE "# scan-to-python.pl $cfgFile $outFile\n");
    printf(OUTFILE "# Config file contents:\n");
    printf(OUTFILE "#    %32s    %6s    %6s    %6s\n", "Field Name", "Dir", "Width", "Mult");
    writeCommentSeparator(0);
    my $chainLength = 0;
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        # Total field width = field width x field multiplier
        my $totalFieldWidth = $chainConfig[$i][2] * $chainConfig[$i][3];
        printf(OUTFILE "#    %32s    %6s    %6d    %6d\n", $chainConfig[$i][0], $chainConfig[$i][1], $chainConfig[$i][2], $chainConfig[$i][3]);
        # Sum chain length
        $chainLength = $chainLength + $totalFieldWidth;
    }
    printf(OUTFILE "#\n# Scan Chain Module Name = %s\n", $moduleName);
    printf(OUTFILE "# Scanchain Length = %d\n", $chainLength);
    writeCommentSeparator(0);
#    printf(OUTFILE "\nfrom numpy import binary_repr\n\n");
}

sub writeClass
{
    writeCommentHeader(0, "Class $moduleName");
    printf(OUTFILE "class %s:\n", $moduleName);
    printf(OUTFILE "\n");
}

sub writeConstructor
{
    writeCommentHeader(1, "Constructor");
    # print definition line
    printf(OUTFILE "    def __init__(self, \n");
    # Fields as part of the function arguments
    my $chainLength = 0;
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        # Total field width = field width x field multiplier
        my $totalFieldWidth = $chainConfig[$i][2] * $chainConfig[$i][3];
        # Print the full field in the format of:
        # FIELDNAME =     '0'*LENGTH
        printf(OUTFILE "        %-36s = %s * %-6d, \n",
            $chainConfig[$i][0],
            '\'0\'', $totalFieldWidth);
        # Add to chain length
        $chainLength += $totalFieldWidth;
    }
    printf(OUTFILE "        %-36s = %s * %-6d):\n\n",
            'filler', '\'0\'', 0);

    # Put all fields into self, starting with filler
    printf(OUTFILE "        self.%-36s = %s\n", "filler", 'filler');
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        printf(OUTFILE "        self.%-36s = %s\n",
            $chainConfig[$i][0], $chainConfig[$i][0]);
    }

    printf(OUTFILE "        \n");
    writeCommentSeparator(1);
    printf(OUTFILE "    \n");
}

sub writeLength
{
    writeCommentHeader(1, "Get scan chain length");
    # Calculate length of the scan
    my $chainLength = 0;
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        # Total field width = field width x field multiplier
        $chainLength += $chainConfig[$i][2] * $chainConfig[$i][3];
    }
    printf(OUTFILE "    \@staticmethod\n");
    printf(OUTFILE "    def length(): \n");
    printf(OUTFILE "        return %d\n\n", $chainLength);
#    printf(OUTFILE "    def length(self): \n");
#    printf(OUTFILE "        return %d\n\n", $chainLength);

    printf(OUTFILE "    \@staticmethod\n");
    printf(OUTFILE "    def length_static(): \n");
    printf(OUTFILE "        return %d\n\n", $chainLength);

    writeCommentSeparator(1);
    printf(OUTFILE "    \n");
}

sub writeToBits
{
    writeCommentHeader(1, "Construct bits from class");
    # The to_bits method
    printf(OUTFILE "    def to_bits(self): \n");
    printf(OUTFILE "        \n");
    # Create bit string by creating a list of strings, then calling str.join
    # Faster than native concatenation
    printf(OUTFILE "        bits = ''.join([bit_val for bit_val in [\n");
    for (my $i = @chainConfig - 1; $i >= 0; $i--)
    {
        printf(OUTFILE "            self.%s,\n", $chainConfig[$i][0]);
    }
    printf(OUTFILE "        ]])\n");
#
#    printf(OUTFILE "        bits = str.join('', [\n");
#    for (my $i = @chainConfig - 1; $i >= 0; $i--)
#    {
#        # Concatenate
#        printf(OUTFILE "            self.%s,\n", $chainConfig[$i][0]);
#    }
#    printf(OUTFILE "        ])\n");

#    # create bit string by concatenation
#    printf(OUTFILE "        bits = %s\n", 'self.filler');
#    # Print concatenation of the scan bits
#    for (my $i = @chainConfig - 1; $i >= 0; $i--)
#    {
#        # Concatenate
#        printf(OUTFILE "        bits += self.%s\n", $chainConfig[$i][0]);
#    }

    # Calculate total scan chain length
    my $chainLength = 0;
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        # Total field width = field width x field multiplier
        $chainLength += $chainConfig[$i][2] * $chainConfig[$i][3];
    }

    # Print check string
    printf(OUTFILE "        \n");
    printf(OUTFILE "        # Output check\n");
    printf(OUTFILE "        if len(%s) != %s:\n", "bits", "self.length()");
    printf(OUTFILE "            raise ValueError(\"Error, expecting %d bits, got \" + str(len(%s)) + \"!\")\n",
        $chainLength, "bits");
    printf(OUTFILE "        \n");
    printf(OUTFILE "        # Return output\n");
    printf(OUTFILE "        return bits\n");
    printf(OUTFILE "        \n");
    writeCommentSeparator(1);
    printf(OUTFILE "    \n");
}

sub writeFromBits()
{
    writeCommentHeader(1, "Update class from bits");
    # The from_bits class method
    printf(OUTFILE "    def from_bits(self, bits): \n");
    printf(OUTFILE "        \n");
    # Calculate total scan chain length
    my $chainLength = 0;
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        # Total field width = field width x field multiplier
        $chainLength += $chainConfig[$i][2] * $chainConfig[$i][3];
    }

    # Input check
    printf(OUTFILE "        # Check length of bits\n");
    printf(OUTFILE "        if len(%s) != %d:\n", "bits", $chainLength);
    printf(OUTFILE "            raise ValueError(\"Error, expecting %d bits, got \" + str(len(%s)) + \"!\")\n",
        $chainLength, "bits");
    printf(OUTFILE "        \n");

    # Update the fields
    # Python does everything backwards, stupid python
    my $curIndex = 0;
    for (my $i = @chainConfig - 1; $i >= 0; $i--)
    {
        # Add entry
        printf(OUTFILE "        self.%-36s = bits[%6d:%-6d]\n", $chainConfig[$i][0],
            $curIndex, $curIndex + $chainConfig[$i][2] * $chainConfig[$i][3]);
        $curIndex += $chainConfig[$i][2] * $chainConfig[$i][3];
    }
    printf(OUTFILE "        self.%-36s = '0' * 0\n", 'filler');
    printf(OUTFILE "            \n");
    writeCommentSeparator(1);
    printf(OUTFILE "    \n");
}

sub writeCreateFromBits()
{
    writeCommentHeader(1, "Construct class from bits");
    # The from_bits class method
    printf(OUTFILE "    \@classmethod\n");
    printf(OUTFILE "    def create_from_bits(cls, bits): \n");
    printf(OUTFILE "        \n");
    # Calculate total scan chain length
    my $chainLength = 0;
    for (my $i = 0; $i < @chainConfig; $i++)
    {
        # Total field width = field width x field multiplier
        $chainLength += $chainConfig[$i][2] * $chainConfig[$i][3];
    }

    # Input check
    printf(OUTFILE "        # Check length of bits\n");
    printf(OUTFILE "        if len(%s) != %d:\n", "bits", $chainLength);
    printf(OUTFILE "            raise ValueError(\"Error, expecting %d bits, got \" + str(len(%s)) + \"!\")\n",
        $chainLength, "bits");
    printf(OUTFILE "        \n");

    # Create the class from the bits
    printf(OUTFILE "        # Create class\n");
    printf(OUTFILE "        return cls( \n");
    # Python does everything backwards, stupid python
    my $curIndex = 0;
    for (my $i = @chainConfig - 1; $i >= 0; $i--)
    {
        # Add entry
        printf(OUTFILE "            %-36s = bits[%6d:%-6d], \n", $chainConfig[$i][0],
            $curIndex, $curIndex + $chainConfig[$i][2] * $chainConfig[$i][3]);
        $curIndex += $chainConfig[$i][2] * $chainConfig[$i][3];
    }
    printf(OUTFILE "            %-36s = '0' * 0)\n", 'filler');
    printf(OUTFILE "            \n");
    writeCommentSeparator(1);
    printf(OUTFILE "    \n");
}

sub writeCommentSeparator
{
    my $string = "";
    for (my $i = 0; $i < $_[0]; $i++)
    {
        $string .= "    ";
    }

    $string .= "# ";
    for (my $i = 0; $i < 91 - $_[0]*8; $i++)
    {
        $string .= "-";
    }
    printf(OUTFILE "%s\n", $string);
}

sub writeCommentHeader
{
    writeCommentSeparator($_[0]);
    my $string = "";
    for (my $i = 0; $i < $_[0]; $i++)
    {
        $string .= "    ";
    }
    $string .= "#";
    printf(OUTFILE "%s    %s\n", $string, $_[1]);
    writeCommentSeparator($_[0]);
}

sub addField
{
    my $fieldName = $_[0];
    my $fieldDir = $_[1];
    my $fieldWidth = $_[2];
    my $fieldMult = $_[3];

    if (!$fieldWidth) {die "Field width for '$fieldName' cannot be 0 or undefined!"};

    # Add to the list of config fields
    push(@chainConfig, [$fieldName, $fieldDir, $fieldWidth, $fieldMult]);
}

sub log2
{
    return ceil(log($_[0])/log(2));
}

sub writeGetWriteBits
{
    writeCommentHeader(1, "Get write bits from class");
    # The to_bits method
    printf(OUTFILE "    def get_write_bits(self): \n");
    printf(OUTFILE "        \n");
    # Create bit string by creating a list of strings, then calling str.join
    # Faster than native concatenation
    printf(OUTFILE "        bits = ''.join([bit_val for bit_val in [\n");
    for (my $i = @chainConfig - 1; $i >= 0; $i--)
    {
        if ($chainConfig[$i][1] eq 'W') {
            printf(OUTFILE "            self.%s,\n", $chainConfig[$i][0]);
        } else {
            printf(OUTFILE "            # self.%s,\n", $chainConfig[$i][0]);
        }
    }
    printf(OUTFILE "        ]])\n");

#    # Calculate total scan chain length
#    my $chainLength = 0;
#    for (my $i = 0; $i < @chainConfig; $i++)
#    {
#        # Total field width = field width x field multiplier
#        $chainLength += $chainConfig[$i][2] * $chainConfig[$i][3];
#    }
#
#    # Print check string
#    printf(OUTFILE "        \n");
#    printf(OUTFILE "        # Output check\n");
#    printf(OUTFILE "        if len(%s) != %s:\n", "bits", "self.length()");
#    printf(OUTFILE "            raise ValueError(\"Error, expecting %d bits, got \" + str(len(%s)) + \"!\")\n",
#        $chainLength, "bits");
    printf(OUTFILE "        \n");
    printf(OUTFILE "        # Return output\n");
    printf(OUTFILE "        return bits\n");
    printf(OUTFILE "        \n");
    writeCommentSeparator(1);
    printf(OUTFILE "    \n");
}