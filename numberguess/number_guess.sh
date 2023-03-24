#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --no-align -t -c"
#get username
echo "Enter your username:"
read username
#get userinfo
userid=$($PSQL "select user_id from users where username='$username'")
if [[ -z $userid ]]
  then
  newuser=$($PSQL "insert into users(username) values('$username')")
  userid=$($PSQL "select user_id from users where username='$username'")
  #welcome new user if not found
  echo "Welcome, $username! It looks like this is your first time here."
  else
  games=$($PSQL "select games_played from users where user_id=$userid")
  best=$($PSQL "select best_game from users where user_id=$userid")
  #print user gamehistory if found
  echo "Welcome back, $username! You have played $games games, and your best game took $best guesses."
fi
#generate random number
tries=0
answer=$(( $RANDOM % 1000 + 1))
#echo $answer
echo "Guess the secret number between 1 and 1000:"
read guess
updategames=$($PSQL "update users set games_played=games_played + 1 where user_id=$userid")
#guess logic
while true
do
  #check if guess is an integer
  if [[ $guess =~ ^[0-9]+$ ]]
  then
    (( tries++ ))
    #check if guess is lower/higher
    if [[ $guess -lt $answer ]]
    then
    echo "It's higher than that, guess again:"
    read guess
    elif [[ $guess -gt $answer ]]
    then
    echo "It's lower than that, guess again:"
    read guess
    else
    break
    fi
  else
  echo "That is not an integer, guess again:"
  read guess
  fi
done

echo "You guessed it in $tries tries. The secret number was $guess. Nice job!"
best=$($PSQL "select best_game from users where user_id=$userid")
#check if game was a highscore 
if [[ $tries < $best ]] || [[ -z $best ]]
then
  updatebest=$($PSQL "update users set best_game=$tries where user_id=$userid")
fi
