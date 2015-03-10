global class AccountStackOppsByType {
    
    /**
        Change !!ONLY!! this Line to alter the currency prefix
    **/
    static final String CURRENCY_SYMBOL = '$';
    
    

    private final Account act;
    public String filterCriteria {get; set;}
    
    
    public AccountStackOppsByType(ApexPages.StandardController controller) {
        act = (Account) controller.getRecord();
    }
    
    public String getCurrencySymbol() {
        return CURRENCY_SYMBOL;
    }
    
    public List<SelectOption> getFilterCriteriaOptions() {
        List<SelectOption> options = new List<SelectOption>();        
        options.add(new SelectOption('ALL_TIME', 'All Time'));
        options.add(new SelectOption('THIS_MONTH', 'This Month'));
        options.add(new SelectOption('THIS_FQ', 'This Fiscal Quarter'));
        options.add(new SelectOption('THIS_FY', 'This Fiscal Year'));        
        options.add(new SelectOption('NEXT_MONTH', 'Next Month'));
        options.add(new SelectOption('NEXT_FQ', 'Next Fiscal Quarter'));
        options.add(new SelectOption('NEXT_FY', 'Next Fiscal Year'));        
        options.add(new SelectOption('PREV_MONTH', 'Previous Month'));
        options.add(new SelectOption('PREV_FQ', 'Previous Fiscal Quarter'));
        options.add(new SelectOption('PREV_FY', 'Previous Fiscal Year'));        
        return options;
    }
    
    @remoteAction
    global static Map<String, List<OppSummary>> getFilteredOpportunityDetails(String accountId, String filterBy) {
        Map<String, List<OppSummary>> oppStageToAmmount = new Map<String, List<OppSummary>>();        
        List<AggregateResult> results = NULL;        
        if(filterBy == 'ALL_TIME') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC]; 
        } else if(filterBy == 'THIS_MONTH') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = THIS_MONTH GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'THIS_FQ') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = THIS_FISCAL_QUARTER GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'THIS_FY') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = THIS_FISCAL_YEAR GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'NEXT_MONTH') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = NEXT_MONTH GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'NEXT_FQ') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = NEXT_FISCAL_QUARTER GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'NEXT_FY') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = NEXT_FISCAL_YEAR GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'PREV_MONTH') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = LAST_MONTH GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'PREV_FQ') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = LAST_FISCAL_QUARTER GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'PREV_FY') {
            results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = LAST_FISCAL_YEAR GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        } else {
           results = [Select o.StageName, o.Type, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId GROUP BY StageName, Type ORDER BY SUM(o.Amount) DESC];
        }
        
        for(AggregateResult result : results) {
            List<OppSummary> oppSummaryForStage = new List<OppSummary>();
            String oppStage = (String)result.get('StageName');
            if(oppStageToAmmount.containsKey(oppStage)) {
                oppSummaryForStage.addAll(oppStageToAmmount.get(oppStage));
            }
            
            oppSummaryForStage.add(new OppSummary((String)result.get('StageName'), (String)result.get('Type'), (Decimal)result.get('sum')));
            
            
            oppStageToAmmount.put(oppStage,oppSummaryForStage);
            
            //(Decimal)result.get('sum'));
        }
        return oppStageToAmmount;                   
    }
    
    

}