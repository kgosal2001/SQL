SELECT DEST_COUNTRY_NAME, sum(count) as total_flights_from_US
FROM flights
WHERE ORIGIN_COUNTRY_NAME = 'United States' AND DEST_COUNTRY_NAME <> 'United States'
group by DEST_COUNTRY_NAME
order by total_flights_from_US desc