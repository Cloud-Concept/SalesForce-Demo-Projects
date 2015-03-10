<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unique_Id_on_Sales</fullName>
        <field>UniqueId__c</field>
        <formula>Date_Text__c &amp; &quot;|&quot; &amp; Product__r.Id &amp; &quot;|&quot; &amp; Brick__r.Id</formula>
        <name>Update Unique Id on Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Unique Id on Sales</fullName>
        <actions>
            <name>Update_Unique_Id_on_Sales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
