---selecting SOME COVID TABLE DATA to look at
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2


----- checking a location's (eg; Papau New Guinea's) INFECTED POPULATION as per DATE
SELECT location,date,total_cases,population,(total_cases/population)*100 as Infected_percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location like '%Papua New Guinea%' 
ORDER BY 1,2


----- Each Loction's Highest Infection Count of # people
SELECT location,MAX(total_cases) as Highiest_InfectionCount,population,MAX((total_cases/population))*100 as Infected_percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
Group By location,population 
ORDER BY Infected_percentage DESC 


----Showing a location's (CITY'S & cOUNTRY'S)  Highiest Death Count (descending order)
SELECT location,MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
Group BY location
ORDER BY TotalDeathCount desc


---- a CONTINENT's  Highiest Death Count
SELECT continent ,MAX(CAST (total_deaths as int)) as HighestDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
Group BY continent
ORDER BY HighestDeathCount desc


----Chances of Dying from covid as per deaths vs population 
SELECT location,MAX(CAST(total_deaths as int)) as Highest_DeathCount,MAX(total_cases) as InfectedCases,population,
max(total_deaths)/population*100 as DyingChances_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
where    (total_cases is not null)
     or (total_deaths is not null)
	 or (total_cases >total_deaths)
Group BY location,population 
ORDER BY DyingChances_Percentage desc  



--- (join & CTE) Part(1)--Total percentage of population vaccinated as per location---distinctively
WITH PopVac (location,population,TotalPopVaccinated) as
(
SELECT dea.location,dea.population,MAX(vac.total_vaccinations) over (partition by vac.location)
 FROM PortfolioProject1.dbo.CovidDeaths dea
 JOIN PortfolioProject1.dbo.CovidVaccination vac
 ON  (dea.location=vac.location )  and (dea.date=vac.date)
          where (dea.continent is not null) 
            and ( vac.new_vaccinations is not null)
)
SELECT distinct location, population,TotalPopVaccinated,(TotalPopVaccinated/population) *100 as VaccPercentage
FROM PopVac
where population >= TotalPopVaccinated
order by VaccPercentage desc


--(JOIN & TEMP TABLE) Part(2) Percentage of Population Vaccinated distinctively
DROP Table IF EXISTS #PercentPopVaccinated 
CREATE TABLE #PercentPopVaccinated 
(
location nvarchar (255),
 population numeric,
 TotalPopVaccinated numeric
 )
 INSERT INTO #PercentPopVaccinated
SELECT dea.location,dea.population
  ,MAX(vac.total_vaccinations) over (partition by vac.location) as TotalPopVaccinated

FROM PortfolioProject1.dbo.CovidDeaths dea
   JOIN PortfolioProject1.dbo.CovidVaccination vac
   ON  (dea.location=vac.location )  and (dea.date=vac.date)
          where (dea.continent is not null) 
            and ( vac.new_vaccinations is not null)

SELECT distinct location, population,TotalPopVaccinated
     ,(TotalPopVaccinated/population) *100 as VaccPercentage

FROM #PercentPopVaccinated
where population >= TotalPopVaccinated
order by VaccPercentage desc



