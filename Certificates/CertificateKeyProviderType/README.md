Zertifikate werden mittels der Cryptographic API oder Cryptiography Next Generation API erstellt.
Das sind so gennannte Key Provider (CSP)

| Anbieter	|Beschreibung|
|----|----|
|Microsoft Base Cryptographic Provider|	Eine breite Palette grundlegender kryptografischer Funktionen, die in andere Länder oder Regionen exportiert werden können.
|Microsoft starker Kryptografieanbieter	|Eine Erweiterung des Microsoft Base Cryptographic Provider, die mit Windows XP und höher verfügbar ist.|
|Microsoft Enhanced Cryptographic Provider|	Microsoft Base Cryptographic Provider mit über längere Schlüssel und zusätzliche Algorithmen.|
|Microsoft AES-Kryptografieanbieter|	Microsoft Enhanced Cryptographic Provider mit Unterstützung für AES-Verschlüsselungsalgorithmen.|
|Microsoft DSS-Kryptografieanbieter|	Bietet Hashing-, Datensignatur- und Signaturüberprüfungsfunktionen mithilfe der Algorithmen Secure Hash Algorithm (SHA)und Digital Signature Standard (DSS).|
|Microsoft Base DSS und Diffie-Hellman Cryptographic Provider	|Eine Obermenge des DSS-Kryptografieanbieters, der auch Diffie-Hellman-Schlüsselaustausch, Hashing, Datensignatur und Signaturüberprüfung mithilfe der Algorithmen Secure Hash Algorithm (SHA) und Digital Signature Standard (DSS) unterstützt.|
|Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider	|Unterstützt Diffie-Hellman Schlüsselaustausch (eine 40-Bit-DES-Ableitung), SHA-Hashing, DSS-Datensignatur und DSS-Signaturüberprüfung.|
|Microsoft DSS und Diffie-Hellman/Schannel Cryptographic Provider	|Unterstützt Hashing, Datensignierung mit DSS, generieren Diffie-Hellman(D-H)-Schlüssel, Austauschen von D-H-Schlüsseln und Exportieren eines D-H-Schlüssels. Dieser CSP unterstützt die Schlüsselableitung für die Protokolle SSL3 und TLS1.|
|Microsoft RSA/Schannel Cryptographic Provider	|Unterstützt Hashing, Datensignatur und Signaturüberprüfung. Der Algorithmusbezeichner CALG _ SSL3 SHAMD5 wird für die _ SSL 3.0- und TLS 1.0-Clientauthentifizierung verwendet. Dieser CSP unterstützt die Schlüsselableitung für die Protokolle SSL2, PCT1, SSL3 und TLS1.|
|Microsoft RSA Signature Cryptographic Provider|	Bietet Datensignatur und Signaturüberprüfung.Die Anbieter können im Cmdlet New-SelfSignedCertificate mit dem Parameter -Provider definiert werden.

Neue Windows Versionen erstellen immer die private Keys eines Zertifikats mittels CNG.
Der Parameter -keySpec bei Cmdlet New-SelfSignedCertificate definiert, ob der im Zertifikat enthaltene Private Key ein CNG oder non-CNG Key ist. Ohne den Parameter wird dem Zertifikat kein private Key hinzugefügt. 

If the private key is managed by a legacy CSP, the value is KeyExchange or Signature. If the key is managed by a Cryptography Next Generation (CNG) KSP, the value is None.

Aus <https://docs.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2019-ps> 

CNG Keys können bspw nicht bei der App-Only Authentfizierung für Exchange Online verwendet werden.

## How to use
    Get-CertificateKeyProviderType.ps1 -CertificateLocation Cert:\LocalMachine\My

![Cert](https://github.com/pascalrimark/PowerShell/blob/main/Certificates/CertificateKeyProviderType/Images/CertImage.png?raw=true)