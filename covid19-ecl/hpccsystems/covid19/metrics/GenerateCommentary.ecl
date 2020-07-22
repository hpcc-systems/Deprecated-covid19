IMPORT $.Types2 AS Types;
IMPORT Python3 AS Python;

metricsRec := Types.metricsRec;

EXPORT STRING GenerateCommentary(DATASET(metricsRec) recs, UNSIGNED minActive, UNSIGNED infPeriod, REAL parent_cfr) := EMBED(Python)
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
