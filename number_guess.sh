#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo "Enter your username: "
read USERNAME
RANDOM_NUMBER=$((1 + RANDOM % 1000))
SELECTED_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")


#if username not found
if [[ -z $SELECTED_USER ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users (username) VALUES('$USERNAME')")
  echo "Welcome, '$USERNAME'! It looks like this is your first time here."
else
#if username found
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) 
  FROM games 
  JOIN users ON games.user_id = users.user_id 
  WHERE users.username = '$USERNAME';")

  BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games 
  JOIN users ON games.user_id = users.user_id
  WHERE users.username = '$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
fi

#GRAB USER ID
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

#REMOVE AFTER!!!!!!!!!!!!!!!!!!!!!!!
echo $USER_ID
echo "$RANDOM_NUMBER"


TRIES=0
GUESS=0

until [ $RANDOM_NUMBER == $GUESS ]
do
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    (( TRIES++ ))
    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $RANDOM_NUMBER ]]
    then       
      echo "It's higher than that, guess again:"
    fi
  fi
done



#insert data
INSERTED_GAME_INFO=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")

#if equal to random_number
echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
