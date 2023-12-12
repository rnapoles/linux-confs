#!/bin/bash
echo Año 2007
read year
echo Mes 01-12
read mes
echo Día 01-31
read day
echo Hora 01-24
read hora
echo Minuto 00-59
read minuto

hwclock --set --date="$mes/$day/$year $hora:$minuto:00"
date -s "$year$mes$day $hora:$minuto:00" 
