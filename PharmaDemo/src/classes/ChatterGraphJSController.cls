public class ChatterGraphJSController {
  Map<String, List<String>> graph = new Map<String, List<String>>(); // Subscriber to parents
  Map<String, Map<String, String>> dataMap = new Map<String, Map<String, String>>(); // Id to data
  Set<String> processedIds = new Set<String>(); // Previous degrees
  Set<String> processingIds = new Set<String>(); // Current degree
  Set<String> pendingIds = new Set<String>(); // Next degree
  
  public String getJson() {
    Map<string,string> params = ApexPages.currentPage().getParameters();
    String levelParam = params.get('level');
    if (isNullOrEmpty(levelParam)) levelParam = '3';
    String centerParam = params.get('center');
    if (isNullOrEmpty(centerParam)) centerParam = UserInfo.getUserId();
    
    String typesParam = params.get('types');
    if (typesParam == null) typesParam = 'User';
    Map<String, String> typeToFilter = new Map<String, String>();
    List<String> types = typesParam.split('::', -1);
    for (String typeString : types) {
      List<String> typeAndCondition = typeString.split(':');
      if (typeAndCondition.size() == 1) {
        typeAndCondition.add('');
      }
      typeToFilter.put(typeAndCondition[0].toLowerCase(), typeAndCondition[1]);
    }
    
    return getJson(centerParam, Integer.valueOf(levelParam), typeToFilter);
  }
  
  private Boolean isNullOrEmpty(String str) {
    return str == null || str == '';
  }
  
  private void putNodeData(String id, String name) {
    Map<String, String> nodeData = new Map<String, String>();
    nodeData.put('name', name);
    dataMap.put(id, nodeData);
  }
  
  public String getJson(String homeNodeId, Integer levelLimit, Map<String, String> typeToFilter) {
    if (levelLimit > 5) levelLimit = 5;
    
    putNodeData(homeNodeId, UserInfo.getName());
    pendingIds.add(homeNodeId);
    
    try {
      for (Integer i=0; i<levelLimit && !pendingIds.isEmpty(); i++) {
        transferAll(pendingIds, processingIds);
        Map<String, List<EntitySubscription>> filteringIdToEss = new Map<String, List<EntitySubscription>>();
        
        for (EntitySubscription es :
          [SELECT SubscriberId, ParentId, Subscriber.Name, Parent.Name, Parent.Type FROM EntitySubscription
          WHERE (SubscriberId IN :processingIds OR ParentId IN :processingIds)
          AND Parent.Type IN :typeToFilter.keySet() ORDER BY CreatedDate]
        ) {
          if (typeToFilter.get(es.Parent.Type.toLowerCase()) != '') {
            List<EntitySubscription> ess = filteringIdToEss.get(es.ParentId);
            if (ess == null) {
              ess = new List<EntitySubscription>();
              filteringIdToEss.put(es.ParentId, ess);
            }
            ess.add(es);
          } else {        
            processEntitySubscription(es);
          }
        }
        
        for (String typeName : typeToFilter.keySet()) {
          String typeFilter = typeToFilter.get(typeName);
          if (typeFilter != '') {
            Set<String> filteringIdToEssKeySet = filteringIdToEss.keySet();
            for (SObject so : Database.query('SELECT Id FROM ' + typeName + ' WHERE Id IN :filteringIdToEssKeySet AND ' + typeFilter)) {
              for (EntitySubscription es : filteringIdToEss.get(so.Id)) {
                processEntitySubscription(es);
              }
            }
          }
        }
        
        transferAll(processingIds, processedIds);
      }
      
      // Add ending nodes
      for (String id : processedIds) {
        getOrAddParendId(id);
      }
      
      List<String> graphStrings = new List<String>();
      getGraphStrings(homeNodeId, graphStrings);
      
      return '[' + join(graphStrings, ',') + ']';
    } catch(Exception e) {
      return 'Exception: ' + e.getTypeName() + ' - ' + e.getMessage();
    }
  }
  
  private void processEntitySubscription(EntitySubscription es) {
    if ((processingIds.contains(es.SubscriberId) && isProcessedOrProcessing(es.ParentId))
        || (processingIds.contains(es.ParentId) && isProcessedOrProcessing(es.SubscriberId))) {
      List<String> parentIds = getOrAddParendId(es.SubscriberId);
      parentIds.add(es.ParentId);
      putNodeData(es.SubscriberId, es.Subscriber.Name);
      putNodeData(es.ParentId, es.Parent.Name);
    }
    
    if (!isProcessedOrProcessing(es.SubscriberId)) {
      pendingIds.add(es.SubscriberId);
    }
    if (!isProcessedOrProcessing(es.ParentId)) {
      pendingIds.add(es.ParentId);
    }
  }
  
  private Boolean isProcessedOrProcessing(String id) {
    return processedIds.contains(id) || processingIds.contains(id);
  }
  
  private void transferAll(Set<String> src, Set<String> dest) {
    dest.addAll(src);
    src.clear();
  }
  
  private List<String> getOrAddParendId(String subscriberId){
    List<String> parentIds = graph.get(subscriberId);
    if (parentIds == null) {
      parentIds = new List<String>();
      graph.put(subscriberId, parentIds);
    }
    return parentIds;
  }
  
  private void getGraphStrings(String homeNodeId, List<String> graphStrings) {
    graphStrings.add(getNodeString(homeNodeId));
    
    for (String id : graph.keySet()) {
      if (id != homeNodeId) {
        graphStrings.add(getNodeString(id));
      }
    }
  }
  
  private String getNodeString(String id) {
    String adjacenciesString = join(graph.get(id), '","');
    if (adjacenciesString.length() > 0) {
      adjacenciesString = '"' + adjacenciesString + '"';
    }
    return '{id:"' + id + '",name:"' + jsonEscape(dataMap.get(id).get('name')) + '",adjacencies:[' + adjacenciesString + '],data:{type:""}}';
  }
  
  private String join(List<String> pieces, String delim) {
    if (pieces == null || pieces.size() == 0) return '';
    
    String result = '';
    for (String s : pieces) {
      result += (s + delim);
    }
    return result.substring(0,result.length() - delim.length());
  }
  
  private String jsonEscape(String src) {
    return src.replace('"', '\\"');
  }
}