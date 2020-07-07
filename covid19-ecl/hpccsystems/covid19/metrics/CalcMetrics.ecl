IMPORT $.Types;
IMPORT Python3 AS Python;
metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
statsExtRec := Types.statsExtRec;

EXPORT CalcMetrics := MODULE
  SHARED InfectionPeriod := 10;
  SHARED periodDays := 7;
  SHARED scaleFactor := 5;  // Lower will give more hot spots.
  SHARED minActDefault := 20; // Minimum cases to be considered emerging, by default.
  SHARED minActPer100k := 30; // Minimum active per 100K population to be considered emerging.
  SHARED infectedConfirmedRatio := 3.0; // Calibrated by early antibody testing (rough estimate), and ILI Surge statistics.

  EXPORT DATASET(statsExtRec) DailyStats(DATASET(statsRec) stats, UNSIGNED asOfDate = 0) := FUNCTION
    stats0 := IF(asOfDate = 0, stats, stats(date < asOfDate));
    statsS := SORT(stats0, location, -date);
    statsE0 := PROJECT(statsS, TRANSFORM(statsExtRec, SELF.id := COUNTER, SELF := LEFT));
    latestDate := MAX(statsE0, date);
    obsoleteLocations := DEDUP(statsS, location)(date < latestDate);
    statsE1 := JOIN(statsE0, obsoleteLocations, LEFT.location = RIGHT.location, LEFT ONLY);
    // Compute the extended data
    // Extend data with previous reading on each record. Note: sort is descending by date, so current has lower id
    statsE2 := ASSERT(JOIN(statsE1, statsE1, LEFT.location = RIGHT.location AND LEFT.id = RIGHT.id - 1,
                  TRANSFORM(RECORDOF(LEFT),
                        SELF.prevCases := RIGHT.cumCases,
                        SELF.newCases := IF(LEFT.cumCases >= RIGHT.cumCases, LEFT.cumCases - RIGHT.cumCases, 0),
                        SELF.prevDeaths := RIGHT.cumDeaths;
                        SELF.newDeaths := IF(LEFT.cumDeaths >= RIGHT.cumDeaths, LEFT.cumDeaths - RIGHT.cumDeaths, 0),
                        SELF.periodCGrowth := IF(SELF.prevCases > 0, SELF.newCases / SELF.prevCases, 0),
                        SELF.periodMGrowth := IF(SELF.prevDeaths > 0, SELF.newDeaths / SELF.prevDeaths, 0),
                        SELF := LEFT), LEFT OUTER),newCases >= 0, 'Warning: newCases < 0.  Location = ' + location + '(' + date + ')');

    // Go infectionPeriod days back to see how many have recovered and how many are still active
    statsE3 := JOIN(statsE2, statsE2, LEFT.location = RIGHT.location AND LEFT.id = RIGHT.id - InfectionPeriod, TRANSFORM(RECORDOF(LEFT),
                        SELF.active := IF (LEFT.cumCases >= RIGHT.cumCases, LEFT.cumCases - RIGHT.cumCases, 0),
                        SELF.recovered := IF(RIGHT.cumCases < LEFT.cumDeaths, 0, RIGHT.cumCases - LEFT.cumDeaths),
                        SELF.prevActive := IF(LEFT.prevCases >= RIGHT.prevCases, LEFT.prevCases - RIGHT.prevCases, 0),
                        SELF.cfr := LEFT.cumDeaths / RIGHT.cumCases,
                        SELF := LEFT), LEFT OUTER);
    statsE := statsE3;
    RETURN statsE;
  END;
  // Calculate Metrics, given input Stats Data.
  EXPORT DATASET(metricsRec) WeeklyMetrics(DATASET(statsRec) stats, DATASET(populationRec) pops, UNSIGNED minActive = minActDefault, DECIMAL5_3 parentCFR = 0, UNSIGNED asOfDate = 0) := FUNCTION
    STRING generateCommentary(DATASET(metricsRec) recs, UNSIGNED minActive, UNSIGNED infPeriod, REAL parent_cfr) := EMBED(Python)
      import time
      from math import log
      def numFormat(num):
        number_with_commas = "{:,}".format(num)
        return number_with_commas
      def doublingTime(r, infPeriod):
        return round(log(2.0**infPeriod, r))
      outstr = ''
      stateMap = {'Initial':0, 'Recovered':0, 'Recovering':1, 'Stabilized':2, 'Stabilizing':3, 'Emerging':4, 'Spreading':5}
      for rec in recs:
        location = rec[1].strip()
        startDate = rec[3]
        endDate = rec[4]
        iState = rec[5].strip()
        cases = rec[6]
        deaths = rec[7]
        active = rec[8]
        cr = rec[9]
        mr = rec[10]
        r = rec[11]
        sdi = rec[12]
        mdi = rec[13]
        hi = rec[14]
        cfr = rec[15]
        infCount = rec[16]
        immunePct = rec[17]
        newCases = rec[18]
        newDeaths = rec[19]
        newCasesDaily = rec[20]
        newDeathsDaily = rec[21]
        peakCases = rec[29]
        peakDeaths = rec[30]
        periodDays = rec[33]
        prevState = rec[34].strip()
        sti = rec[35]
        ewi = rec[36]
        surgeStart = rec[38]
        currIFR = rec[39]
        ifr = rec[40]
        cRisk = rec[42] # Contagion Risk
        if r < 1:
          if r == 0:
            sev = 1.0
          else:
            sev = 1/r
        else:
          sev = r
        adv = ''
        if sev > 2:
          adv = 'very quickly '
        elif sev > 1.5:
          adv = 'quickly '
        elif sev < 1.05:
          adv = ''
        elif sev < 1.1:
          adv = 'very slowly '
        elif sev < 1.3:
          adv = 'slowly '
        if sev < 1.05:
          dir = 'steady'
        elif r > 1.0:
          dir = 'increasing'
        else:
          dir = 'decreasing'
        implstr = adv + dir
        iStateNum = stateMap[iState]
        prevStateNum = stateMap[prevState]
        if iState == 'Emerging':
          article = 'an '
        else:
          article = 'a '
        if iStateNum == prevStateNum:
          if iState == prevState:	
            outstr = location + ' remains in ' + article + iState + ' state. '
          else:
            outstr = location + ' is currently in ' + article + iState + ' state. '
        elif iStateNum > prevStateNum:
          outstr = location + ' has worsened to ' + article + iState + ' state from a previous state of ' + prevState + '. '
        else:
          outstr = location + ' has improved to ' + article + iState + ' state from a previous state of ' + prevState + '. '
        if r > 0:
          rstr = 'The infection is ' + implstr + ' (R = ' + str(r) + '). '
        else:
          rstr = 'It is too early to estimate the growth rate (R). '
        relapsestr = 'This represents a regression from a previous state of ' + prevState + '. '
        if iState != 'Recovered':
          outstr += rstr
        scaleStr = 'There are currently ' + numFormat(active) + ' active cases. '
        if iState == 'Emerging':
          scaleStr = 'This outbreak is based on a small number of active infections (' + numFormat(active) + ') and may be contained by appropriate measures. '
          # if prevState in ['Recovered', 'Recovering', 'Stabilized', 'Stabilizing']:
          #		scaleStr += relapsestr
        elif iState == 'Spreading':
          scaleStr = 'At this growth rate, new infections and deaths will double every ' + str(doublingTime(r, infPeriod)) + ' days. '
          probStr = 'probably '
          if cases > 10 * minActive:
            probStr = ''
          scaleStr += 'This outbreak is ' + probStr + 'beyond containment, with ' + numFormat(active) + ' active cases, and requires mitigation. '
          # if prevState in ['Recovered', 'Recovering', 'Stabilized', 'Stabilizing']:
          #		scaleStr += relapsestr
        elif iState == 'Regressing':
          scaleStr = 'The infection was previously recovering, but has recently begun to grow again (' + numFormat(active) + ' active cases, ' + \
                        numFormat(newCases) + ' new). '
        elif iState == 'Initial':
          scaleStr = 'No significant infection has been detected. '
        elif iState == 'Stabilized':
          scaleStr += 'At this rate, expect to see approximately ' + numFormat(newCases) + ' new cases and ' + numFormat(newDeaths) + ' deaths per week. '
          # if prevState in ['Recovering', 'Recovered']:
          #		scaleStr += relapsestr
        elif iState == 'Stabilizing':
          scaleStr = 'At this growth rate, new infections and deaths will double every ' + str(doublingTime(r, infPeriod)) + ' days. '
          # if prevState in ['Recovering', 'Recovered', 'Stabilized']:
          #		scaleStr += relapsestr
        elif iState == 'Recovered':
          scaleStr = 'No significant active infections remain. '
        elif iState == 'Recovering':
          casePct = 0
          deathsPct = 0
          if peakCases > 0:
            casePct = (peakCases - newCases) / float(peakCases) * 100
          if peakDeaths > 0:
            deathsPct = (peakDeaths - newDeaths) / float(peakDeaths) * 100
          scaleStr += 'New Cases are currently ' + numFormat(newCases) + ' per week, down ' + str(round(casePct)) + '% from a peak of ' + numFormat(peakCases) + ' per week. '
          scaleStr += 'New Deaths are currently ' + numFormat(newDeaths) + ' per week, down ' + str(round(deathsPct)) + '% from a peak of ' + numFormat(peakDeaths) + ' per week. '
        outstr += scaleStr
        infstr = ''
        if infCount > 1:
          ord = 'th'
          if infCount == 2:
            ord = 'nd'
          elif infCount == 3:
            ord = 'rd'
          surgedat = time.strptime(str(surgeStart), '%Y%m%d')
          surgedatstr = time.strftime('%b %d, %Y', surgedat)
          infstr = 'This is the ' + str(infCount) + ord + ' surge in infections, which started on the week of ' + surgedatstr + '. '
        outstr += infstr
        peakstr = ''
        if infCount == 1:
          surgestr = ''
        else:
          surgestr = ' during this surge'
        if newCases >= peakCases and newDeaths >= peakDeaths and peakDeaths > 0:
          peakstr += 'With ' + numFormat(newCases) + ' new cases and ' + numFormat(newDeaths) + ' new deaths, this is the worst week yet for cases and deaths' + surgestr + '. '
        else:
          if newCases >= peakCases and peakCases > 0:
            peakstr += 'With ' + numFormat(newCases) + ' new cases, this is the worst week so far for cases' + surgestr + '. '
          if newDeaths >= peakDeaths and peakDeaths > 0:
            peakstr += 'With ' + numFormat(newDeaths) + ' new deaths, this is the worst week so far for deaths' + surgestr + '. '
        if surgeStart != startDate:
          # Suppress if this is the first week of the new surge
          outstr += peakstr
        riskstr = 'The Contagion Risk is '
        if cRisk >= .5:
          riskscale = 'extremely high  '
        elif cRisk >= .25:
          riskscale = 'very high '
        elif cRisk >= .15:
          riskscale = 'high '
        elif cRisk >= .05:
          riskscale = 'moderate '
        elif cRisk >= .01:
          riskscale = 'relatively low '
        elif cRisk >= .005:
          riskscale = 'very low '
        else:
          riskscale = 'negligible '
        riskscale += 'at ' + str(round(cRisk * 100, 1)) + '%. '
        riskstr += riskscale
        riskstr += 'This is the likelihood of meeting an infected person during one hundred random encounters. '
        outstr += riskstr
        sdString = ''
        sdscalestr = 'slightly'
        if abs(sdi) > .6:
          sdscalestr = 'dramatically'
        elif abs(sdi) > .4:
          sdscalestr = 'significantly'
        if sdi < -.1 and iState not in ['Recovered']:
          sdString = 'It appears that the level of social distancing has decreased ' + sdscalestr + ', resulting in higher levels of infection growth. '
          outstr += sdString
        elif sdi >= .1:
          sdString = 'It appears that the level of social distancing has increased ' + sdscalestr + ', resulting in lower levels of infection growth. '
          outstr += sdString 
        if mdi < -.1:
          mdString = 'The mortality rate is growing faster than the case rate, implying that there may be a deterioration in medical conditions, probably indicating '
          if r >= 1.5 and active > minActive:
            mdReason = 'an overload of the local medical capacity. '
          else:
            mdReason = 'inadequate testing availability. '
          mdString += mdReason
          caveatStr = ''
          if newDeaths < 100:
            caveatStr = 'With only ' + str(newDeaths) + ' deaths, this could easily be caused by a statistical or reporting anomaly. '
          outstr += mdString + caveatStr
        hiString = ''
        if hi >= 1.0:
          hiReason = ' various factors. '
          hiString = location + ' is currently on the HotSpot list due to '
          if r > 1.5 or cr > 1.5:
            hiReason = ' rapid increase in cases. '
            if r < 1.5:
              hiReason += 'The increase has not yet shown up in the R calculation because of a much lower growth in deaths.  See the Metrics page for details. '
          elif mr > 1.5:
            hiReason = ' a high increase in deaths. '
          elif cRisk > .25:
            hiReason = ' high risk of contagion. '
          elif sdi < 0 or mdi < 0:
            if sdi < mdi:
              hiReason = ' apparent decrease in social distancing measures. '
            else:
              hiReason = ' apparent deterioration of medical conditions. '
          hiString += hiReason
          outstr += hiString
        if cfr > 0:
          cfrstr = 'The Case Fatality Rate (CFR) is estimated as ' + str(round(cfr * 100.0, 2)) + '%. '
          if parent_cfr > 0:
            if cfr > 1.8 * parent_cfr:
              cmp = 'much higher than '
            elif cfr > 1.2 * parent_cfr:
              cmp = 'significantly higher than '
            elif cfr < .55 * parent_cfr:
              cmp = 'much lower than '
            elif cfr < .8 * parent_cfr:
              cmp = 'significantly lower than '
            else:
              cmp = 'consistent with '
            cfrstr += 'This is ' + cmp + 'the average CFR of ' + str(round(parent_cfr * 100.0, 2)) + '%. '
            cfrRatio = cfr / parent_cfr
            if cfrRatio > 3 or cfrRatio < 1/3.0:
              cfrstr += 'It is likely that ' + location + ' uses a different reporting protocol than its peers.  '
          outstr += cfrstr
        immunestr = 'Preliminary antibody testing suggests that ' + str(round(immunePct)) + '% of the population may have been infected and are presumed immune. '
        if immunePct < 10:
          immunestr += 'This is not enough to significantly slow the spread of the virus. '
        elif immunePct < 25:
          immunestr += 'This may be enough to slightly suppress the spread of the virus. '
        elif immunePct < 50:
          immunestr += 'This should significantly suppress the spread of the virus. '
        elif immunePct > 50:
          immunestr += 'This location is approaching herd immunity and should not see significant further spread. '
        immunestr += 'This preliminary testing also implies an Infection Fatality Rate (IFR) of roughly ' + str(round(ifr*100, 1)) + '%. '
        if immunePct > .5:
          outstr += immunestr
        stistr = ''
        if sti < -.1:
          stistr = 'The Short-Term Indicator suggests that the infection is likely to worsen over the course of the next few days.'
        elif sti > .1:
          stistr = 'The Short-Term Indicator(STI) suggests that the infection is likely to slow somewhat over the next few days.'
        outstr += stistr
        ewistr = ''
        if ewi < -.5:
          ewistr = 'The Early Warning Indicator at ' + str(ewi) + ' implies that a significant increase in infection growth rate is imminent. '
        elif ewi > .5:
          ewistr = 'The Early Warning Indicator (' + str(ewi) + ') implies that a slowdown in infection growth rate is imminent. '
        outstr += ewistr
      return outstr
    ENDEMBED;

    statsE := DailyStats(stats, asOfDate);
    // Now combine the records for each week.
    // First add a period to records for each state
    statsGrpd0 := GROUP(statsE, location);
    statsGrpd1 := PROJECT(statsGrpd0, TRANSFORM(RECORDOF(LEFT), SELF.period := (COUNTER-1) DIV periodDays + 1, SELF := LEFT));
    statsGrpd := GROUP(statsGrpd1, location, period);
    metricsRec doRollup(statsExtRec r, DATASET(statsExtRec) recs) := TRANSFORM
        SELF.location := r.location;
        SELF.fips := r.fips;
        SELF.period := r.period;
        cRecs := recs(cumCases > 0);
        mRecs := recs(cumDeaths > 0);
        cCount := COUNT(crecs);
        lastC := cRecs[1];
        firstC := cRecs[cCount];
        mCount := COUNT(mrecs);
        lastM := mRecs[1];
        firstM := mRecs[mCount];
        SELF.startDate := firstC.date;
        SELF.endDate := lastC.date;
        SELF.periodDays := IF(cCount = 0, SKIP, cCount);
        SELF.cases := lastC.cumCases;
        SELF.deaths := lastM.cumDeaths;
        SELF.newCases := IF(lastC.cumCases > firstC.prevCases, lastC.cumCases - firstC.prevCases, 0);
        SELF.newDeaths := IF(lastM.cumDeaths > firstM.prevDeaths, lastM.cumDeaths - firstM.prevDeaths, 0);
        SELF.newCasesDaily := IF(lastC.cumCases > lastC.prevCases, lastC.cumCases - lastC.prevCases, 0);
        SELF.newDeathsDaily := IF(lastM.cumDeaths > lastM.prevDeaths, lastM.cumDeaths - lastM.prevDeaths, 0);
        SELF.active := lastC.active,
        SELF.recovered := lastC.recovered,
        SELF.cfr := lastC.cfr,
        SELF.ifr := SELF.cfr / infectedConfirmedRatio;
        cGrowth := SELF.newCases / firstC.active;
        cR_old := POWER(cGrowth, InfectionPeriod/cCount);  // Old CR calc might be useful later
        SELF.cR_old := MIN(cR_old, 9.99);
    END;

    metrics0 := ROLLUP(statsGrpd, GROUP, doRollup(LEFT, ROWS(LEFT)));
    metrics1 := JOIN(metrics0, pops, LEFT.location = RIGHT.location, TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF (RIGHT.population > 0, RIGHT.population, 1),
                                SELF.cases_per_capita := IF(SELF.population > 1, LEFT.cases * 100000 / SELF.population, 0),
                                SELF.deaths_per_capita := IF(SELF.population > 1, LEFT.deaths * 100000 / SELF.population, 0),
                                SELF.contagionRisk := IF(SELF.population > 1, 1 - (POWER(1 - (LEFT.active * infectedConfirmedRatio / SELF.population), 100)), 0),
                                SELF.immunePct := IF(SELF.population > 1, LEFT.recovered / SELF.population * infectedConfirmedRatio * 100, 0),
                                SELF := LEFT), LEFT OUTER);
    metricsRec calc1(metricsRec l, metricsRec r) := TRANSFORM
        prevNewCases := IF(r.newCases > 0, r.newCases, 1);
        cGrowth := l.newCases / prevNewCases;
        cR := MIN(POWER(cGrowth, InfectionPeriod/periodDays), 9.00);
        SELF.cR := cR;
        prevNewDeaths := IF(r.newDeaths > 0, r.newDeaths, 1);
        mGrowth :=  l.newDeaths / prevNewDeaths;
        mR := MIN(POWER(mGrowth, InfectionPeriod/periodDays), 9.99);
        SELF.mR := mR;
        // Use Geometric Mean of cR and mR to compute an estimate of R,
        // since we're working with growth statistics.
        R1 := IF(SELF.mR > 0 AND SELF.cR > 0, POWER(MIN(SELF.cR, SELF.mR + 1) * MIN(SELF.mR, SELF.cR + 1), .5), IF(SELF.cR > 0, SELF.cR, SELF.mR));
        SELF.R := R1;
        SELF.cmRatio := IF(mR > 0, cR / mR, 0);
        SELF.dcR := IF(r.cR > 0, cR / r.cR, 0);
        SELF.dmR := IF (r.mR > 0, l.mR / r.mR, 0);
        //SELF.medIndicator := IF(R1 > 1 AND SELF.cmRatio > 0 AND r.cmRatio > 0, l.cmRatio / r.cmRatio - 1, 0);
        medIndicator := IF(cR > 1.1 AND SELF.cmRatio < 1 AND SELF.cmRatio > 0, -(1/SELF.cmRatio - 1), IF(SELF.cmRatio > 1, SELF.cmRatio - 1, 0));
        SELF.medIndicator := MAX(MIN(medIndicator, 5), -5); 
        //SELF.sdIndicator := IF(R1 > 1, -SELF.dcR, 0);
        SELF.sdIndicator := MAX(MIN(IF(SELF.dcR >= 1, -(SELF.dcR - 1), 1/SELF.dcR - 1), 5), -5);
        // Assume that cR decreases with the inverse log of time.  First we calculate the base of the log
        b := POWER(10, (l.cR/r.cR * LOG(periodDays)));
        wtp0 := POWER(b, l.cR - 1);
        // Don't project beyond 10 weeks
        wtp := IF(wtp0 > 10, 999, wtp0);
        SELF.weeksToPeak := IF(l.cR > 1, IF(l.cR < r.cR, wtp, 999), 0);  // Needs to move to later.
        cSTI := IF(l.newCases > 0, l.newCasesDaily / (l.newCases / l.periodDays), 1);
        mSTI := IF(l.newDeaths > 0,  l.newDeathsDaily / (l.newDeaths / l.periodDays), 1);
        // Average case and death indicators and bound to range (.1, 10)
        STI0 := MIN(MAX((cSTI + mSTI) / 2.0, .1), 10);
        // Convert from ratio to indicator  (Negative is bad -- more than average cases on last day)
        STI := IF(STI0 <= 1.0, (1 / STI0) - 1, -(STI0 - 1));
        SELF.sti := STI;
        SELF.currCFR := l.newDeaths / r.active;
        EWI := IF(SELF.sdIndicator < -.2 AND SELF.medIndicator > .2, SELF.sdIndicator - SELF.medIndicator,
                  IF(SELF.sdIndicator > .2 AND SELF.medIndicator < -.2, SELF.sdIndicator - SELF.medIndicator, 0));
        SELF.ewi := EWI;
        SELF := l;
    END;
    // Join twice to force all of the dependent calculations to be there.
    metrics2 := JOIN(metrics1, metrics1, LEFT.location = RIGHT.location AND LEFT.period = RIGHT.period - 1,
                        calc1(LEFT, RIGHT), LEFT OUTER);
    metrics3 := JOIN(metrics2, metrics2, LEFT.location = RIGHT.location AND LEFT.period = RIGHT.period - 1,
                        calc1(LEFT, RIGHT), LEFT OUTER);

    // Gavin, why is this calculation wrong occasionally?
    metrics4 := ASSERT(PROJECT(metrics3, TRANSFORM(RECORDOF(LEFT),
                                    SELF.heatIndex := LOG(LEFT.active) * (IF(LEFT.cR > 1, LEFT.cR - 1, 0) +
                                            IF(LEFT.mr > 1,LEFT.mR - 1, 0) +
                                            IF(LEFT.medIndicator < 0, -LEFT.medIndicator, 0) +
                                            IF(LEFT.sdIndicator < 0, -LEFT.sdIndicator, 0))  / scaleFactor,
                                    SELF := LEFT)), heatIndex = 0 OR (cR > 0 OR mR > 0 OR medIndicator < 0 OR sdIndicator < 0 ), 'hi: ' + location + ',' + heatIndex + ',' + active + ',' + cR + ',' + mR + ',' + medIndicator + ',' + sdIndicator);
    metricsRec calc2(metricsRec l, metricsRec r) := TRANSFORM
        prevState := IF(l.location = r.location, l.iState, 'Initial');
        SELF.prevState := prevState;
        prevInfectCount := IF(l.location = r.location, l.infectionCount, 1);
        R1 := r.R;
        isOverMin := IF(r.population > 1, r.active / r.population * 100000 > minActPer100k OR r.active > minActive, r.active > minActive);
        SELF.iState := MAP(
            //prevState in ['Recovered', 'Recovering'] AND R1 >= 1.1 => 'Regressing',
            prevState = 'Initial' AND r.active = 0 => 'Initial',
            //prevState in ['Initial', 'Recovered', 'Recovering'] AND R1 > 1.1 AND r.active >= 1 AND r.active < minActive => 'Emerging',
            R1 > 1.5 AND r.active >= 1 AND NOT isOverMin => 'Emerging',
            R1 >= 1.5 => 'Spreading',
            R1 >= 1.1 AND R1 < 1.5 => 'Stabilizing',
            R1 >= .9 AND R1 < 1.1 => 'Stabilized',
            prevState != 'Initial' AND (R1 > .1 OR isOverMin) => 'Recovering',
            prevState != 'Initial' AND R1 <= .1 AND NOT isOverMin => 'Recovered',
            'Initial');
        wasRecovering := IF(l.location = r.location, IF(SELF.iState IN ['Recovered', 'Recovering'], TRUE, l.wasRecovering), FALSE);
        SELF.infectionCount := IF(wasRecovering AND self.iState IN ['Stabilizing', 'Emerging', 'Spreading'], prevInfectCount + 1, prevInfectCount);
        SELF.wasRecovering := IF(SELF.infectionCount > prevInfectCount, FALSE, wasRecovering);
        SELF.surgeStart := IF(SELF.prevState = 'Initial' OR SELF.infectionCount > prevInfectCount, r.startDate, l.surgeStart);
        SELF.peakCases := IF(l.location = r.location, IF(r.newCases > l.peakCases OR SELF.infectionCount > prevInfectCount, r.newCases, l.peakCases), r.newCases);
        SELF.peakDeaths := IF(l.location = r.location, IF(r.newDeaths > l.peakDeaths OR SELF.infectionCount > prevInfectCount, r.newDeaths, l.peakDeaths), r.newDeaths);			
        cR := IF(r.cR > 1, r.cR - 1, 0);
        mR := IF(r.mR > 1, r.mR - 1, 0);
        mi := IF(r.medIndicator < 0, -r.medIndicator / 2.5, 0);
        sdi := IF(r.sdIndicator < 0, -r.sdIndicator / 2.5, 0);
        SELF.heatIndex := LOG(r.active) * (MIN(cR, mR + 1) + MIN(mR, cR+1) + mi + sdi + r.contagionRisk) / scaleFactor;
        SELF := r;          
    END;
    metrics5 := SORT(metrics4, location, -period);
    metrics6 := ITERATE(metrics5, calc2(LEFT, RIGHT));
    metricsRec addCommentary(metricsRec rec) := TRANSFORM
      SELF.commentary := generateCommentary(DATASET([rec], metricsRec), minActive, InfectionPeriod, parentCFR);
      SELF := rec;
    END;
    metrics7 := PROJECT(metrics6, addCommentary(LEFT));
    metrics := SORT(metrics7, location, period);
    return metrics;
  END;  // Weekly metrics
END; // CalcMetrics