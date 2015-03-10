global class OppSummary {
    public String stageName {get; set;}
    public String stageType {get; set;}
    public Decimal totalOppValue {get; set;}
    
    public OppSummary(String name, String type, Decimal value) {
        stageName = name;
        stageType = type;
        totalOppValue = value;
       
    }
}