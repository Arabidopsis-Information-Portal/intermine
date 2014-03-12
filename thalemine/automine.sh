#!/bin/bash
#
# default usage: automine.sh
#
# note: you should put the db password in ~/.pgpass if don't
#       want to be prompted for it
#
# sc 09/08
#

# see after argument parsing for all envs related to the release

DATADIR=/micklem/data/thalemine

LOGDIR=$DATADIR/logs

PROPDIR=$HOME/.intermine
#SCRIPTDIR=../bio/scripts/thalemine

ARKDIR=/micklem/releases/thalemine

RECIPIENTS=contrino@flymine.org

# set minedir and check that thalemine in path
MINEDIR=$PWD
BUILDDIR=$MINEDIR/integrate/build

#--rm?
pwd | grep thalemine > pathcheck.tmp
if [ ! -s pathcheck.tmp ]
then
echo "EXITING: you should be in the thalemine directory from your checkout."
echo
rm pathcheck.tmp
exit;
fi
rm pathcheck.tmp
#--mr


# default settings: edit with care
WEBAPP=y         # build a webapp
BUILD=y          # build thalemine
#CHADOAPPEND=n    # rebuild the chado db
BUP=n            # don't do a back up copy of the databases
V=               # non-verbose mode
REL=dev;         # if no release is passed, do a dev (unless validating or making a full release)
#STAG=y           # run stag loading
TEST=n           # no acceptance tests
#VALIDATING=n     # not running as a validation
#FOUND=n          # y if new files downloaded
INFILE=          # not using a given list of submissions
INTERACT=n       # y: step by step interaction
#WGET=y           # use wget to get files from ftp
PREP4FULL=n      # don't run get_all_thalemine (only in F mode)
STOP=n           # y if warning in the setting of the directories for chado.
#STAGFAIL=n       # y if stag failed. when validating, we skip the failed sub and continue
P=               # no project declared

# these are mutually exclusive
# should be enforced
INCR=n
FULL=n
META=n           # it builds a new mine with static and metadata only
RESTART=n        # restart building recovering last dumped db
QRESTART=n       # restart building using current db

progname=$0

function usage () {
  cat <<EOF

Usage:
$progname [-F] [-M] [-R] [-V] [-P] [-L] [-I] [-f file_name] [-g] [-i] [-r release] [-s] [-v] DCCid
  -F: full (thalemine) rebuild (Uses thalemine-build as default)
  -M: test build (metadata only)
  -R: restart full build after failure
  -V: validation mode: all new entries,one at the time (Uses thalemine-val as default)
    -P project_name: as -M, but restricted to a project.
    -L list of projects: as -M, but using a (comma separated) list of projects.
    -I: do an incremental build (add modENCODE data to existing mine).
  -f file_name: using a given list of submissions
  -g: no checking of ftp directory (wget is not run)
  -i: interactive mode
  -r release: specify which instance to use (val, dev, test, build). Default is dev (not with -V or -F)
  -s: no new loading of chado (stag is not run)
  -v: verbode mode

In addition to those:
Advanced Usage switches: [-a] [-b] [-p] [-t] [-w] [-x]
  -a: append to chado
  -b: don't build a back-up of modchado-$REL
  -p: prepare chadoxml directories and update the sources (run get_all_thalemine). Valid only in F mode
  -t: no acceptance test run
  -w: no new webapp will be built
  -x: don't build thalemine (!: used for running only tests)


Parameters: you can process
            a single submission                   (e.g. automine.sh 204 )
            a list of submission in an input file (e.g. automine.sh -V -f infile )
            all the available submissions         (e.g. automine.sh -F )

            you can also pass the release, overwriting the default
                                                  (e.g. automine.sh -F -r test )

Notes: The file is downloaded only if not present or the remote copy
       is newer or has a different size.

       With the -I switch is used, the submissions found in the relevant chado
       (default modchado-dev) are ADDED to the relevant thalemine (default: thalemine-dev)

       If no uppercase switch is used (V, M, F, R, P, L, I), the local project.xml is used.

examples:

$progname     add new submissions to thalemine-dev, getting new files from ftp
$progname 123 add submission 123 to thalemine-dev, getting it from ftp
$progname -F -r test    build a thalemine-test with metadata, Flybase and Wormbase,
        getting new files from ftp
$progname -M -r test    build a new chado with all the NEW submissions in
        $FTPURL
        and use this to build a thalemine-test
$progname -s -w -t build thalemine-dev using the existing modchado-dev,
        without performing acceptance tests and without building the webapp
$progname -f file_name -r val build thalemine-val using the submissions listed in file_name

EOF
  exit 0
}

echo

while getopts ":FMRQVP:L:Iabf:gipr:stvwx" opt; do
  case $opt in

# F )  echo; echo "Full ThaleMine realease"; FULL=y; BUP=y; INCR=n; REL=build;;
  F )  echo "- Full ThaleMine realease"; FULL=y; REL=build;;
  M )  echo "- Test build (metadata only)"; META=y;;
  R )  echo "- Restart full realease"; RESTART=y; FULL=y; STAG=n; WGET=n; BUP=n; REL=build;;
  Q )  echo "- Quick restart full realease"; QRESTART=y; FULL=y; STAG=n; WGET=n; BUP=n; REL=build;;
#  V )  echo "- Validating submission(s) in $DATADIR/new"; VALIDATING=y; META=y; BUP=n; REL=val;;
#  P )  P=$OPTARG; META=y; P="`echo $P|tr '[A-Z]' '[a-z]'`"; echo "- Test build (metadata only) with project $P";;
#  L )  L=$OPTARG; META=y; L="`echo $L|tr '[A-Z]' '[a-z]'`"; echo "- Test build (metadata only) with projects $L";;
#  I )  echo "- Incremental build (modENCODE data is added to existing mine)"; INCR=y;;
#  a )  echo "- Append data in chado" ; CHADOAPPEND=y;;
#  b )  echo "- Don't build a back-up of the database." ; BUP=n;;
#  p )  echo "- prepare directories for full realease and update all sources (get_all_thalemine is run)" ; PREP4FULL=y;;
  f )  INFILE=$OPTARG; echo "- Using given list of chadoxml files: "; SHOW="`cat $INFILE|tr '[\n]' '[,]'`"; echo $SHOW;;
#  g )  echo "- No checking of ftp directory (wget is not run)" ; WGET=n;;
  i )  echo "- Interactive mode" ; INTERACT=y;;
  r )  REL=$OPTARG; echo "- Using release $REL";;
#  s )  echo "- Using previous load of chado (stag is not run)" ; STAG=n; BUP=n; WGET=n;;
  t )  echo "- No acceptance test run" ; TEST=n;;
  v )  echo "- Verbose mode" ; V=-v;;
  w )  echo "- No new webapp will be built" ; WEBAPP=n;;
  x )  echo "- ThaleMine will NOT be built" ; BUILD=n; BUP=n;;
  h )  usage ;;
  \?)  usage ;;
  esac
done

shift $(($OPTIND - 1))

#
# NOTE: all modencode sources are supposed to be on the same server, etc.
# Getting some values from the properties file.
# -m1 to grep only the first occurrence (multiple modencode sources)
#

MINEHOST=`grep -v "#" $PROPDIR/thalemine.properties.$REL | grep -m1 production.datasource.serverName | awk -F "=" '{print $2}'`
DBUSER=`grep -v "#" $PROPDIR/thalemine.properties.$REL | grep -m1 metadata.datasource.user | awk -F "=" '{print $2}'`
DBPW=`grep -v "#" $PROPDIR/thalemine.properties.$REL | grep -m1 metadata.datasource.password | awk -F "=" '{print $2}'`
MINEDB=`grep -v "#" $PROPDIR/thalemine.properties.$REL | grep -m1 db.production.datasource.databaseName | awk -F "=" '{print $2}'`


#***
LOG="$LOGDIR/$USER.$REL.$P"`date "+%y%m%d.%H%M"`  # timestamp of stag operations + error log

#if [ -n "$P" ]
#then
#SOURCES=thalemine-static,modencode-"$P"-metadata
#elif [ -n "$L" ]
#then
#SOURCES=thalemine-static
#IFS=$','
#for p in $L
#do
#echo "---> $p"
#SOURCES="$SOURCES",modencode-"$p"-metadata
#done
#IFS=$'\t\n'
#else

#SOURCES=chado-db-wormbase-c_elegans,wormbase-c_elegans-chromosome-fasta,modencode-metadata,worm-network
SOURCES=aip-gff,bar

#fi



echo
echo "==================================="
echo "Building thalemine-$REL on $MINEHOST."
echo "==================================="
echo "current directory: $MINEDIR"
echo "Log: $LOG"
if [ "$FULL" = "n" ]
then
echo "Sources: $SOURCES"
fi
echo

#if [ -n "$1" ]
#then
#SUB=$1
#echo "Processing submission $SUB.."
#fi

function setProjectFile {
#------------------------------------------------------------------------
# setting the appropriate project.xml
#
# necessary if we want to maintain generic chado db such as modchado-dev
# in addition to the project ones used for a full build
# e.g. modchado-piano
#
#------------------------------------------------------------------------
RETURNDIR=$PWD

#if [ -n "$P" -o "$FULL" = "y" ]
if [ "$FULL" = "y" ]
then
return
fi

if [ "$META" = "y" -o "$VALIDATING" = "y" ]
then
cd $MINEDIR
if [ -n "$1" ]
then
echo "resetting project.xml.."
# resetting: going back to the normal situation
mv project.xml.original project.xml
else
# setting the dev project
echo "setting the project.xml file for a generic chado..."
cp -u project.xml project.xml.original # cp only if .original is not there
cp $SCRIPTDIR/project.xml .
fi
cd $RETURNDIR
fi

}

function interact {
# if testing, wait here before continuing
if [ $INTERACT = "y" -o $STOP = "y" ]
then
echo "$1"
echo "Press return to continue (^C to exit).."
echo -n "->"
read
fi

}

function runTest {
# run the relevant acceptance tests and name the report
# with dccid if validating
# with $REL_timestamp otherwise
echo
echo "========================"
echo "running acceptance tests"
echo "========================"
echo
cd $MINEDIR/integrate

if [ $FULL = "y" ]
then
ant $V -Drelease=$REL acceptance-tests|| { printf "%b" "\n acceptance test FAILED.\n" ; exit 1 ; }
else
ant $V -Drelease=$REL acceptance-tests-metadata|| { printf "%b" "\n acceptance test FAILED.\n" ; exit 1 ; }
fi

# check chado for new features
# this is done because there is a problem with automount....
ls $REPORTS > /dev/null

cd $MINEDIR
$SCRIPTDIR/add_chado_feats_to_report.pl $DBHOST $CHADODB $DBUSER $BUILDDIR/acceptance_test.html > $REPORTS/$1.html

echo "sending mail!!"
mail -s "$1 report, also in file://$REPORTS/$1.html" $RECIPIENTS < $REPORTS/$1.html
#elinks $REPORTS/$1.html
echo
echo "acceptance test results in "
echo "$REPORTS/$1.html"
echo
}


interact

########################################
#
# MAIN
#
########################################




#----------------------------------------------
# set project.xml file (for full build or dev)
#----------------------------------------------
#setProjectFile

#---------------------------------------
# build thalemine
#---------------------------------------
if [ $BUILD = "y" ]
then
cd $MINEDIR
echo
echo "Building ThaleMine $REL"
echo

if [ $INCR = "y" ]
then
# just add to present mine
# NB: if failing won't stop!! ant exit with 0!
echo; echo "Appending new chado (metadata) to thalemine-$REL.."
cd integrate
ant $V -Drelease=$REL -Dsource=modencode-metadata-inc || { printf "%b" "\n ThaleMine build FAILED.\n" ; exit 1 ; }
elif [ $RESTART = "y" ]
then
# restart build after failure
echo; echo "Restarting build using last available back-up db.."
../bio/scripts/project_build -V $REL $V -l localhost $ARKDIR/build/mod-final.dmp\
|| { printf "%b" "\n ThaleMine build (restart) FAILED.\n" ; exit 1 ; }
elif [ $QRESTART = "y" ]
then
# restart build without recovering last dumped db
echo; echo "Quick restart of the build (using current db).."
../bio/scripts/project_build -V $REL $V -r localhost $ARKDIR/build/mod-final.dmp\
|| { printf "%b" "\n ThaleMine build (quick restart) FAILED.\n" ; exit 1 ; }
elif [ $META = "y" ]
then
# new build. static, metadata, organism
echo "SOURCES: $SOURCES"
../bio/scripts/project_build -a $SOURCES -V $REL $V -b localhost /tmp/mod-meta\
|| { printf "%b" "\n ThaleMine build (only metadata) FAILED.\n" ; exit 1 ; }
#cd postprocess
#ant -v -Daction=set-missing-chromosome-locations -Drelease=$REL\
#|| { printf "%b" "\n ThaleMine build (only metadata) FAILED while setting locations.\n" ; exit 1 ; }
#ant -v -Daction=thalemine-metadata-cache -Drelease=$REL\
#|| { printf "%b" "\n ThaleMine build (only metadata) FAILED while building cache.\n" ; exit 1 ; }
else
# new build, all the sources
# get the most up to date sources ..
#if [ $PREP4FULL = "y" ]
#then
#cd ../bio/scripts
#./get_all_thalemine.sh|| { printf "%b" "\n ThaleMine build (get_all_thalemine.sh) FAILED.\n" ; exit 1 ; }
#fi
# .. and build thalemine
cd $MINEDIR
../bio/scripts/project_build -V $REL $V -b localhost $ARKDIR/build/mod-final.dmp\
|| { printf "%b" "\n ThaleMine build FAILED.\n" ; exit 1 ; }
fi

else
echo
echo "Using previously built ThaleMine."
echo
fi #BUILD=y

#----------------------------------------------
# set project.xml back to the original state
#----------------------------------------------
#setProjectFile back

interact

#---------------------------------------
# building webapp
#---------------------------------------
if [ "$WEBAPP" = "y" ]
then
cd $MINEDIR/webapp
ant -Drelease=$REL $V default remove-webapp release-webapp
fi

interact

#---------------------------------------
# and run acceptance tests
#---------------------------------------
if [ "$TEST" = "y" ] && [ "$VALIDATING" = "n" ]
then
if [ -n "$P" ]
then
NAMESTAMP="$P"_`date "+%y%m%d"`
else
NAMESTAMP="$REL"_`date "+%y%m%d.%H%M"`
fi
runTest $NAMESTAMP
fi

