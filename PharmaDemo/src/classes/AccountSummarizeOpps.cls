global with sharing class AccountSummarizeOpps {
    /**
        Change !!ONLY!! this Line to alter the currency prefix
    **/
    static final String CURRENCY_SYMBOL = '$';
    
    
    
    private final Account act;
    public String filterCriteria {get; set;}
    
    public String getCurrencySymbol() {
        return CURRENCY_SYMBOL;
    }
    
    public AccountSummarizeOpps(ApexPages.StandardController controller) {
        act = (Account) controller.getRecord();
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
    global static Map<String, Decimal> getFilteredOpportunityDetails(String accountId, String filterBy) {
        Map<String, Decimal> oppStageToAmmount = new Map<String, Decimal>();        
        List<AggregateResult> results = NULL;        
        if(filterBy == 'ALL_TIME') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId GROUP BY StageName ORDER BY SUM(o.Amount) DESC]; 
        } else if(filterBy == 'THIS_MONTH') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = THIS_MONTH GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'THIS_FQ') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = THIS_FISCAL_QUARTER GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'THIS_FY') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = THIS_FISCAL_YEAR GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'NEXT_MONTH') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = NEXT_MONTH GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'NEXT_FQ') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = NEXT_FISCAL_QUARTER GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'NEXT_FY') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = NEXT_FISCAL_YEAR GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'PREV_MONTH') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = LAST_MONTH GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'PREV_FQ') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = LAST_FISCAL_QUARTER GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else if(filterBy == 'PREV_FY') {
            results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId AND CloseDate = LAST_FISCAL_YEAR GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        } else {
           results = [Select o.StageName, SUM(o.Amount) sum From Opportunity o where AccountId =: accountId GROUP BY StageName ORDER BY SUM(o.Amount) DESC];
        }
        
        for(AggregateResult result : results) {
            oppStageToAmmount.put((String)result.get('StageName'),(Decimal)result.get('sum'));
        }
        
        
        String JSONString = JSON.serialize(oppStageToAmmount);
        return oppStageToAmmount;
                   
    }

}