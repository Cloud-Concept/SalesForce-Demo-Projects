<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Name_on_Business_Plan_Org</fullName>
        <field>Name</field>
        <formula>Business_Plan__r.Organisation__r.Name</formula>
        <name>Update Name on Business Plan Org</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Name on Business Plan Organsiation</fullName>
        <actions>
            <name>Update_Name_on_Business_Plan_Org</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
