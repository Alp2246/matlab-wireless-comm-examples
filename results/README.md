# MATLAB çıktıları (GitHub)

Bu klasöre **küçük sonuç grafikleri** konur; ham veri ve `.mat` dosyaları repoya eklenmez.

## Kaydetme

Betik çalıştırdıktan sonra:

```matlab
save_github_figure(gcf, 'ornek_adi');
```

Dosya: `results/ornek_adi.png`

## GitHub'a gönderme

PowerShell (repo kökünde):

```powershell
.\push_to_github.ps1 -Message "BPSK BER grafigi eklendi"
```

Veya elle:

```powershell
git add results/ornek_adi.png
git commit -m "BPSK BER grafigi"
git push
```

## Ne yüklenir / yüklenmez

| Yüklenir | Yüklenmez |
|----------|-----------|
| `results/*.png`, `results/*.pdf` | `*.mat`, `*.bin`, ham IF |
| `.m` kaynak kodu | `*.fig`, geçici `.asv` |
