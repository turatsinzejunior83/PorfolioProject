Select * 
From PortolioProject..CovidDeaths
Where continent is not null
order by 3,4
--Select * 
--From PortolioProject..CovidVaccinations
--order by 3,4

---- Selecting data -------------

Select location,date,total_cases,new_cases,total_deaths, population
From PortolioProject..CovidDeaths
order by 1,2


----------Total_Cases Vs Total_Death of Covid for specific country--------------

----------This is likelihood of dying in Rwanda for Covid-------------------

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
From PortolioProject..CovidDeaths
Where location like '%Rwanda%' 
order by 1,2

-------------------------Total_Cases Vs Population ---------------------------------------------

-------Shows Percentage of Population got Covid-19--------------------------------

Select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortolioProject..CovidDeaths
Where location like '%Rwanda%' 
order by 1,2,3,4,5


----------Looking Countries with highest infection rate compared to population-------------------

Select Location,Population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From PortolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-------------------Loking Countries with Higest Deathrate per Population-------------------

Select Location,MAX(cast (total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths 
Where continent is not null
Group by Location
order by TotalDeathCount desc

---------LET'S BREAKDWON FOR CONTINENT------------------

Select location,MAX(cast (total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths 
Where continent is null
Group by location
order by TotalDeathCount desc

---------------sHOWING THE CONTINET WITH THE HIGHEST DEATH COUNT-----------------------------------

Select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths 
Where continent is not null
Group by continent
order by TotalDeathCount desc


----------GLOBAL NUMBERS VIEW--------------------

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage

From PortolioProject..CovidDeaths

--Where location like '%states%'

where continent is not null 

--Group By date

order by 1,2


-----------------------Vaccination Covid-19-------------------------------


-------------------lETS fIRST dROP OUT NULL COLUMNS FROM THE TABLE.---------------------------

Select *

From PortolioProject..CovidVaccinations

ALTER TABLE CovidVaccinations
DROP COLUMN F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24,F25,F26;

-- -------------------------------------Total Population vs Vaccinations-------------------------------------------------------
-- ----------------Shows Percentage of Population that has recieved at least one Covid Vaccine---------------------------------------------------
--------------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3


-----------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3


----------------------------------

----------------USE CTE 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100

From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated