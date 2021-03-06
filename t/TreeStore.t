use v6;
use NativeCall;
use Test;

use Gnome::N::N-GObject;
use Gnome::GObject::Type;
use Gnome::GObject::Value;
use Gnome::Gtk3::TreeModel;
use Gnome::Gtk3::TreeIter;
use Gnome::Gtk3::TreePath;
use Gnome::Gtk3::TreeStore;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gtk3::TreeStore $ts;
my Gnome::Gtk3::TreeIter $iter;
my Gnome::Gtk3::TreeIter $parent-iter;
my Gnome::Gtk3::TreeIter $sibling-iter;
my Gnome::Gtk3::TreePath $tp;
my Array[Gnome::GObject::Value] $va;

enum ColumnNames < Col0 Col1 Col2 >; # Col2 is not used or set!
enum VAEntries < E0 E1 >; # entries in va

my class ShowTabel {
  submethod BUILD ( ) {
    note "\n Row  | Number | String\n------+--------+-------------------";
  }

  method show-entry (
    N-GObject $nc-ts,
    Gnome::Gtk3::TreePath $c-path,
    Gnome::Gtk3::TreeIter $c-iter
  ) {
    my Str $row = $c-path.to-string;
    my Gnome::Gtk3::TreeStore $c-ts .= new(:native-object($nc-ts));
    my Array[Gnome::GObject::Value] $va;
    $va = $c-ts.get-value( $c-iter, Col0, Col1);

    note $row.fmt('%5.5s'), ' | ',
         $va[Col0].get-int.fmt('%6d'), ' | ',
         $va[Col1].get-string;

    $va[Col0].unset;
    $va[Col1].unset;

    0
  }
}

#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $ts .= new(:field-types( G_TYPE_INT, G_TYPE_STRING));
  isa-ok $ts, Gnome::Gtk3::TreeStore, '.new(:field-types)';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $iter = $ts.gtk-tree-store-append(Any);
  is $ts.get-path($iter).to-string, '0', '.gtk-tree-store-append()';
  $ts.set-value( $iter, Col0, 1001);
  $ts.set-value( $iter, Col1, 'duizend en een nacht');
  $va = $ts.get-value( $iter, Col0, Col1);
  is $va[Col0].get-int, 1001, 'col 0:.set-value() / .get-value()';
  is $va[Col1].get-string, 'duizend en een nacht',
      'col 1:.set-value() / .get-value()';
  $va[E0].unset;
  $va[E1].unset;

  $tp .= new(:string('0'));
  $parent-iter = $ts.get-iter($tp);
  $iter = $ts.gtk-tree-store-append($parent-iter);
  is $ts.get-path($iter).to-string, '0:0',
     'path: ' ~ $ts.get-path($iter).to-string;
  $ts.set-value( $iter, Col0, 2);
  $ts.set-value( $iter, Col1, 'en nog wat nachten');
  $va = $ts.get-value( $iter, Col0, Col1);
  is $va[E0].get-int, 2, 'col 0:.set-value() / .get-value()';
  is $va[E1].get-string, 'en nog wat nachten',
      'col 1:.set-value() / .get-value()';
  $va[E0].unset;
  $va[E1].unset;

  $tp .= new(:string('0'));
  $parent-iter = $ts.get-iter($tp);
  $iter = $ts.gtk-tree-store-append($parent-iter);
  $ts.set( $iter, Col0, 3, Col1, 'en nog een zinnetje');
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'en nog een zinnetje', '.gtk-tree-store-set()';
  $va[E0].unset;

  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('0:0')));
  $ts.remove($iter);
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'en nog een zinnetje', '.gtk_tree_store_remove()';
  $va[E0].unset;

  $iter = $ts.insert( Any, 0);
  $ts.set( $iter, Col0, 5005, Col1, 'dus');
  $parent-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('0')));
  $iter = $ts.insert( $parent-iter, 0);
  $ts.set( $iter, Col0, 6, Col1, 'en nog wat');
  $parent-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('0:0')));
  $iter = $ts.insert( $parent-iter, 0);
  $ts.set( $iter, Col0, 7, Col1, 'je kan me wat');

  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('0:0:0')));
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'je kan me wat', '.gtk_tree_store_insert()';
  $va[E0].unset;

  $iter = $ts.insert-before( Any, Any);
  $ts.set( $iter, Col0, 9091, Col1, 'wat zal ik nou weer eens tikken...');
  $parent-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('1')));
  $sibling-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('1:0')));
  $iter = $ts.insert-before( $parent-iter, $sibling-iter);
  $ts.set( $iter, Col0, 1, Col1, 'wat zal ik nou weer eens tikken... deel 2');
  $iter = $ts.insert-before( Any, $sibling-iter);
  $ts.set( $iter, Col0, 2, Col1, 'wat zal ik nou weer eens tikken... deel 3');

  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('1:1')));
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'wat zal ik nou weer eens tikken... deel 3',
     '.gtk_tree_store_insert_before()';
  $va[E0].unset;

  $iter = $ts.insert-after( Any, Any);
  $ts.set( $iter, Col0, 9092, Col1, 'the rain in spain...');
  $parent-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('1')));
  $sibling-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('1:0')));
  $iter = $ts.insert-after( $parent-iter, $sibling-iter);
  $ts.set( $iter, Col0, 1, Col1, 'the rain in spain... deel 2');
  $iter = $ts.insert-after( Any, $sibling-iter);
  $ts.set( $iter, Col0, 2, Col1, 'the rain in spain... deel 3');

  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('1:1')));
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'the rain in spain... deel 3',
     '.gtk_tree_store_insert_after()';
  $va[E0].unset;

  $parent-iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('2')));
  $iter = $ts.insert-with-values(
    $parent-iter, 2, Col0, 101, Col1, 'one o one'
  );

  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('2:2')));
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'one o one', '.insert-with-values()';
  $va[E0].unset;

  $tp .= new(:string('1:0'));
  $parent-iter = $ts.get-iter($tp);
  $iter = $ts.tree-store-prepend($parent-iter);
  $ts.set( $iter, Col0, 123, Col1, 'uno dos tres');
  $va = $ts.get-value( $iter, Col1);
  is $va[E0].get-string, 'uno dos tres', '.gtk-tree-store-prepend()';
  $va[E0].unset;

  ok $ts.is-ancestor( $parent-iter, $iter), '.is-ancestor()';
  is $ts.iter-depth($parent-iter), 1, '.iter-depth()';

  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('2:2')));
  ok $ts.iter-is-valid($iter), '.iter-is-valid()';
  $iter = $ts.get-iter(Gnome::Gtk3::TreePath.new(:string('12:20:1')));
  nok $ts.iter-is-valid($iter), '.iter-is-valid() not valid get-iter() returns Null';

  $ts.foreach( ShowTabel.new, 'show-entry');
  note ' ';


  $ts.tree-store-clear;
  is $ts.iter-n-children(Any), 0, '.tree-store-clear()';

  $ts.foreach( ShowTabel.new, 'show-entry');
  note ' ';
}

#`{{
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
