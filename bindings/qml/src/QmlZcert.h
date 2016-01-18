/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/

#ifndef QML_ZCERT_H
#define QML_ZCERT_H

#include <QtQml>

#include <czmq.h>
#include "qml_czmq_plugin.h"


class QmlZcert : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isNULL READ isNULL)
    
public:
    zcert_t *self;
    
    QmlZcert() { self = NULL; }
    bool isNULL() { return self == NULL; }
    
    static QObject* qmlAttachedProperties(QObject* object); // defined in QmlZcert.cpp
    
public slots:
    //  Return public part of key pair as 32-byte binary string
    byte *publicKey ();

    //  Return secret part of key pair as 32-byte binary string
    byte *secretKey ();

    //  Return public part of key pair as Z85 armored string
    const QString publicTxt ();

    //  Return secret part of key pair as Z85 armored string
    const QString secretTxt ();

    //  Set certificate metadata from formatted string.
    void setMeta (const QString &name, const QString &format);

    //  Unset certificate metadata.
    void unsetMeta (const QString &name);

    //  Get metadata value from certificate; if the metadata value doesn't
    //  exist, returns NULL.                                              
    const QString meta (const QString &name);

    //  Get list of metadata fields from certificate. Caller is responsible for
    //  destroying list. Caller should not modify the values of list items.    
    QmlZlist *metaKeys ();

    //  Save full certificate (public + secret) to file for persistent storage  
    //  This creates one public file and one secret file (filename + "_secret").
    int save (const QString &filename);

    //  Save public certificate only to file for persistent storage
    int savePublic (const QString &filename);

    //  Save secret certificate only to file for persistent storage
    int saveSecret (const QString &filename);

    //  Apply certificate to socket, i.e. use for CURVE security on socket.
    //  If certificate was loaded from public file, the secret key will be 
    //  undefined, and this certificate will not work successfully.        
    void apply (void *zocket);

    //  Return copy of certificate; if certificate is NULL or we exhausted
    //  heap memory, returns NULL.                                        
    QmlZcert *dup ();

    //  Return true if two certificates have the same keys
    bool eq (QmlZcert *compare);

    //  Print certificate contents to stdout
    void print ();

    //  DEPRECATED as incompatible with centralized logging
    //  Print certificate contents to open stream          
    void fprint (FILE *file);
};

class QmlZcertAttached : public QObject
{
    Q_OBJECT
    QObject* m_attached;
    
public:
    QmlZcertAttached (QObject* attached) {
        Q_UNUSED (attached);
    };
    
public slots:
    //  Self test of this class
    void test (bool verbose);

    //  Create and initialize a new certificate in memory
    QmlZcert *construct ();

    //  Accepts public/secret key pair from caller
    QmlZcert *constructFrom (const byte *publicKey, const byte *secretKey);

    //  Load certificate from file
    QmlZcert *load (const QString &filename);

    //  Destroy a certificate in memory
    void destruct (QmlZcert *qmlSelf);
};


QML_DECLARE_TYPEINFO(QmlZcert, QML_HAS_ATTACHED_PROPERTIES)

#endif
/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/
