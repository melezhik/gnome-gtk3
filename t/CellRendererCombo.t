use v6;
use NativeCall;
use Test;

use Gnome::Gtk3::CellRendererCombo;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gtk3::CellRendererCombo $crc;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $crc .= new;
  isa-ok $crc, Gnome::Gtk3::CellRendererCombo, '.new';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}

#-------------------------------------------------------------------------------
subtest 'Inherit ...', {
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
}

#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
