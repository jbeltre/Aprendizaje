#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE  games,teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
  #get team id
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
 

  #if not found
  if [[ -z $TEAM_ID ]]
  then
  #inser team
  INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
  if [[ $INSERT_TEAM_RESULT == "INSERT 0 1"  ]]
  then
  echo Inserted into teams, $WINNER
  fi
  fi

  TEAM_ID2=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  
  if [[ -z $TEAM_ID2 ]]
  then
  #inser team
  INSERT_TEAM_RESULT2=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
  if [[ $INSERT_TEAM_RESULT2 == "INSERT 0 1"  ]]
  then
  echo Inserted into teams, $OPPONENT
  fi
  fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
  #get game id
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  TEAM_ID2=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  GAME_ID= $($PSQL "SELECT year,round,winner_id,opponent_id,winner_goals,opponent_goals FROM games as g inner join teams as t on t.team_id=g.winner_id and t.team_id= g.opponent_id WHERE year=$YEAR AND round='$ROUND' AND winner_id=$TEAM_ID AND opponent_id=$TEAM_ID2;")

  #if not found 
  if [[ -z $GAME_ID ]]
  then
  #insert game
  
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR, '$ROUND',$TEAM_ID,$TEAM_ID2,$WINNER_GOALS,$OPPONENT_GOALS )")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
  echo Inserted into games, $YEAR  $ROUND $TEAM_ID $TEAM_ID2 $WINNER_GOALS $OPPONENT_GOALS 
  fi
  fi

  #first if sentence
  fi

done

pg_dump -cC --inserts -U freecodecamp worldcup > worldcup.sql