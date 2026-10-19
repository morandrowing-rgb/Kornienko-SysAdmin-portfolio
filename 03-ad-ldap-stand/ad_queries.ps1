# Примеры запросов к Active Directory (Windows, модуль ActiveDirectory).
# Запускать на контроллере домена или машине с RSAT. Это примеры для стенда, не боевой скрипт.
# Get-ADUser -Filter * -SearchBase "OU=Users,DC=example,DC=local" -Properties LastLogonDate | Select Name,SamAccountName,Enabled,LastLogonDate
# Get-ADUser -Filter {Enabled -eq $false} | Select Name,SamAccountName   # отключённые учётки
# Get-ADGroupMember -Identity "Domain Admins" | Select Name              # состав группы
# Search-ADAccount -LockedOut                                            # заблокированные учётки
# Get-ADComputer -Filter * -Properties OperatingSystem | Select Name,OperatingSystem
