*** Settings ***
Documentation       Insert the sales data for the week and export it as a PDF.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF


*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open the intranet website
    Login
    Download the Excel File
    Fill the form using the data from the Excel file
    Collect the Results
    Export the table as PDF
    [Teardown]    Logout and Close the browser


*** Keywords ***
Open the intranet website
    open available Browser    https://robotsparebinindustries.com/

Login
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form

Download the Excel File
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True

Fill and submit the form for one person
    [Arguments]    ${sales_rep}
    Input Text    firstname    ${sales_rep}[First Name]
    Input Text    lastname    ${sales_rep}[Last Name]
    Input Text    salesresult    ${sales_rep}[Sales]
    Select From List By Value    salestarget    ${sales_rep}[Sales Target]
    Click Button    Submit

Fill the form using the data from the Excel file
    Open Workbook    SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${sales_rep}    IN    @{sales_reps}
        Fill and submit the form for one person    ${sales_rep}
    END

Collect the Results
    Screenshot
    ...    css:#root > div > div > div > div:nth-child(2) > div.alert.alert-dark.sales-summary
    ...    ${OUTPUT_DIR}${/}sales_summary.png

Export the table as PDF
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf

Logout and Close the browser
    Click Button    Log out
    Close Browser
