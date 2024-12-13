#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

  echo "Enter your username:"
  read INPUT

main_menu() {
  # check database to determine if the username already exists
  USER=$($PSQL "SELECT name FROM users WHERE name='$INPUT'")
    if [[ -z $USER ]]
    then
      USER=$INPUT
      USER_INPUT_RESULT=$($PSQL "INSERT INTO users (name) VALUES ('$USER')")
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER'")
      INSERT_TO_GAMES_RESULT=$($PSQL "INSERT INTO games (user_id, games_played, best_game) VALUES ($USER_ID, 0, 0)")
      echo "Welcome, $USER! It looks like this is your first time here."
    else
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER'")
      GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE user_id = $USER_ID")
      BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE user_id = $USER_ID")
      echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
    

    value_generator
    guessing_game
}

value_generator() {
  VALUE=$(($RANDOM % 1000 + 1))
}

guessing_game() {

  COUNT=1
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  
  while ! [[ $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done

  while [[ $GUESS -ne $VALUE ]]
  do
      if [[ $GUESS -gt $VALUE ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $GUESS -lt $VALUE ]]
      then
        echo "It's higher than that, guess again:"
      fi
    read GUESS
    COUNT=$((COUNT + 1))
  done

        GAMES_PLAYED=$((GAMES_PLAYED + 1))
        GAMES_PLAYED_UPDATE_RESULT=$($PSQL "UPDATE games SET games_played = $GAMES_PLAYED")
        if [[ $BEST_GAME -eq 0 || $COUNT -lt $BEST_GAME ]]
        then 
          BEST_GAME=$($PSQL "UPDATE games SET best_game = $COUNT WHERE user_id = $USER_ID")
        fi
      
    echo "You guessed it in $COUNT tries. The secret number was $VALUE. Nice job!"
    exit
      
}

main_menu