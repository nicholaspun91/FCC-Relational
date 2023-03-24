#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

# check for argument 1 existing
if [[ -z $1 ]]
then
echo "Please provide an element as an argument."
else
# check type of argument 1; if int=>atomicnumber query if str=>symbol/name query
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
  atomicn=$($PSQL "select atomic_number from elements where symbol='$1' or name='$1'")
  else
  # query for existence of atomic number, symbol, name
  atomicn=$($PSQL "select atomic_number from elements where atomic_number=$1")
  fi
  if [[ -z $atomicn ]]
  then
  echo "I could not find that element in the database."
  else
  # get name and symbol of the query
  num=$(echo $atomicn | sed 's/ //')
  name=$($PSQL "select name from elements where atomic_number=$atomicn")
  name=$(echo $name | sed 's/ //')
  symbol=$($PSQL "select symbol from elements where atomic_number=$atomicn")
  symbol=$(echo $symbol | sed 's/ //')
  # return properties if exists
  props=$($PSQL "select atomic_mass, melting_point_celsius, boiling_point_celsius from properties where atomic_number=$atomicn")
  typen=$($PSQL "select type_id from properties where atomic_number=$atomicn")
  # get type from types table
  type=$($PSQL "select type from types where type_id=$typen")
  type=$(echo $type | sed 's/ //')
  echo $props | while read am bar mp bar bp
    do
     echo "The element with atomic number $num is $name ($symbol). It's a $type, with a mass of $am amu. $name has a melting point of $mp celsius and a boiling point of $bp celsius."
    done
  fi
fi

