package aghtls

import (
	"crypto/tls"
	"crypto/x509"
)

// TLSConfigProvider provides TLS configuration to consumers.  Implementations
// must be safe for concurrent use.
type TLSConfigProvider interface {
	// TLSConfig returns a clone of the current TLS configuration.  conf uses
	// GetConfigForClient for automatic updates.
	TLSConfig() (conf *tls.Config)

	// RootCAs returns the current root CA pool.
	RootCAs() (root *x509.CertPool)
}

// EmptyTLSConfigProvider is an empty implementation of the [TLSConfigProvider]
// interface.
type EmptyTLSConfigProvider struct{}

// TLSConfig implements the [TLSConfigProvider] interface for
// EmptyTLSConfigProvider.  It always returns nil.
func (EmptyTLSConfigProvider) TLSConfig() (conf *tls.Config) { return nil }

// RootCAs implements the [TLSConfigProvider] interface for
// EmptyTLSConfigProvider.  It always returns nil.
func (EmptyTLSConfigProvider) RootCAs() (root *x509.CertPool) { return nil }
