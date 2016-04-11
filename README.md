# OSM via osmosis

A repository holding my method for loading California OpenStreetMap
(OSM) data into a database via the program osmosis.

Using osmosis is required because all my geometry code expects those
tables to be there.

# Get a pbf file


Download California (or whichever region interests you) from a
[bulk OpenStreetMap server](http://wiki.openstreetmap.org/wiki/Planet.osm#Worldwide_extract_sources).
My favorite is
[geofabrik](http://download.geofabrik.de/north-america.html).  Grab
the pbf file.  For California, the latest is at
[http://download.geofabrik.de/north-america/us/california-latest.osm.pbf](http://download.geofabrik.de/north-america/us/california-latest.osm.pbf).

```
curl
http://download.geofabrik.de/north-america/us/california-latest.osm.pbf
> california-latest.osm.pbf
```

# Don't use ogr2ogr

Don't use ogr2ogr.  Well, you can use it, but it doesn't make all of
the tables that I need.

To use ogr2ogr, do something like:

```
ogr2ogr -f PostgreSQL PG:'dbname=hpms_geocode user=${PG_USER}' \
        -overwrite --oo MAX_TMPFILE_SIZE=1000 california-latest.osm.pbf \
        -lco COLUMN_TYPES=other_tags=hstore PG_USE_COPY=YES SCHEMA=osm
```

# Use Osmosis


Download osmosis and install it.

## Create a db

```
export PSQL_USER='your user name'
export OSMOSIS_DIR='/path/to/osmosis/dir'
createdb -U ${PSQL_USER} osm
```

## Geo stuff

Then use sqitch to add the geo stuff.


```
cd {where you stashed the repo for calvad_db_geoextensions}
sqitch deploy db:pg:osm

```

## Deploy Osmosis

Then load up the databse rules and regs.  This is not handled with
sqitch yet.  Pop into the sql command line, set the default schema to
osm, and source the osmosis scripts.


```

psql -U ${PSQL_USER} osm

create schema osm;
SET search_path TO osm,public;
\i /home/james/repos/OSM_related/osmosis/package/script/pgsnapshot_schema_0.6.sql
\i /home/james/repos/OSM_related/osmosis/package/script/pgsnapshot_schema_0.6_action.sql
\i /home/james/repos/OSM_related/osmosis/package/script/pgsnapshot_schema_0.6_bbox.sql
\i /home/james/repos/OSM_related/osmosis/package/script/pgsnapshot_schema_0.6_linestring.sql
```

### Nota Bena

That above is a hack.  You can't just cut and paste.  Make sure the
paths are correct, etc.


## Parse and process the OSM snapshot with osmosis

Next parse the osm.pbf file

I like to use a directory with lots of space to store temp files and
such.

```
wget http://download.geofabrik.de/north-america/us/california-latest.osm.pbf
export OSMOSIS_FILE=california-latest.osm.pbf
```


Then run osmosis on the file to create a set of sql files that will
generate the osm database using \copy commands.


```

export JAVACMD_OPTIONS="-Xmx2G -Djava.io.tmpdir=/var/tmp/osmosis_data"
export OSMOSIS_DATA=/var/tmp/osmosis_data

/home/james/bin/osmosis \
      -v 100 \
  --read-pbf file=${OSMOSIS_FILE} \
      --buffer bufferCapacity=10000 \
  --write-pgsql-dump-0.6 directory=${OSMOSIS_DATA} \
  			    enableBboxBuilder=true \
 		    enableLinestringBuilder=true \
 		    nodeLocationStoreType=CompactTempFile
```

The -bb (bounding box) line is included because it forces osmosis to
clean up some inconsistencies that appear sometimes in the dumps.
The `write-pgsql-dump` command creates a set of files in
`${OSMOSIS_DATA}` that will populate the database tables.


You will see a lot of dumping output, and then a big pause after the
message

```
FINE: Waiting for task 1-read-pbf to complete.
```

The osmosis run will crash if you don't have enough space on your
drive.  I had 7GB and it crashed, so I upped it to 50GB and it worked
okay.  Your mileage may vary.

Have another cup of coffee.  Go for a bike ride.

## Load OSM data into postgresql

Once the OSM pbf file has been broken into sql statements, you can
then read it into your prepared database.

Load the data into your osm database using a modified version of the
script provided in the `sql` directory of this repo.

```
export CWD=`pwd`
cd ${OSMOSIS_DATA}  # the directory with the dump files
psql -U ${PSQL_USER} osm -f ${CWD}/sql/pgsnapshot_load_0.6.sql
```

This takes a while, but if all goes well you should have an OSM dataset
consistent with whatever the date was from the original download.

## Clean up

Finally get rid of the temporary files in the ${OSMOSIS_DATA}
directory.

# Prepping OSM for VDS work

Now you can run the sqitch code to deploy the scripts to set up for
segmentizing the VDS and WIM sites.
