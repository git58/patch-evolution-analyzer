#!/usr/bin/env bash
# Генератор кодовых имён (пример: cosmic-raccoon, stellar-lynx)

ADJECTIVES=(
  agile ancient arcane atomic bold brave bright cosmic curious
  daring dark dynamic eager electric epic eternal exotic fast
  fiery focal gentle giant golden graceful grand green happy
  humble icy infinite jammy joyful keen kind lucky magic noble
  precise quick quiet radiant rapid rare red robust shiny silent
  small smooth solar speedy stellar strong sturdy swift tiny
  trusty vivid wild wise young
)

NOUNS=(
  antelope badger bear beetle bison camel cat cheetah cobra
  coyote crab crow dolphin dragon eagle elephant falcon ferret
  fox frog gazelle goat gorilla hawk hedgehog hippo horse
  jaguar kangaroo koala leopard lion llama lynx monkey moose
  mouse octopus owl panda panther parrot penguin pony porcupine
  rabbit raccoon raven rhino shark sloth snake spider squid
  squirrel tiger tortoise turtle viper whale wolf yak zebra
)

ADJ=${ADJECTIVES[$RANDOM % ${#ADJECTIVES[@]}]}
NOUN=${NOUNS[$RANDOM % ${#NOUNS[@]}]}

echo "$ADJ-$NOUN"
