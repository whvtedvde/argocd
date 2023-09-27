{{/* library template for Submariner Operator/CTRL definition */}}
{{/* TESTED OK : 17/02/2023 */}}
{{/*
######################################
    Parametre / Values
######################################
submariner:
  submariner:
    name:
    namespace:
    # OPT
    airGappedDeployment:
    broker: k8s
    brokerK8sApiServer: 'api.paiprodn.620nm.net:6443'
    # OPT
    brokerK8sApiServerToken: >-
      eyJhbGciOiJSUzI1NiIsImtpZCI6IkhSY2w4WUp2NFl2MVEtbmJvbUZFUV9YMk5GaTFyaWhhN2NjVlhoWWw0dnMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzdWJtYXJpbmVyLWs4cy1icm9rZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiY2x1c3Rlci1tYXN0ZXIxbi10b2tlbi1iY3NqOCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJjbHVzdGVyLW1hc3RlcjFuIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYjEwOThkZWQtMzEzZi00NjZjLWI0NWItYTU3OTRmMGNjZDg4Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnN1Ym1hcmluZXItazhzLWJyb2tlcjpjbHVzdGVyLW1hc3RlcjFuIn0.Nm3VpUvwDbT_kOw-BwP18LS8xOvX1Pft2Mb27_wcBHntgXiFK69LQ9D33BQCqPN_sOpuFH7qIonHUPw0HkHDYGXys_3QvcmumsjsdOSIHSfZZl9JX4MCasfa6hqHELKlnD8VmCkzumPHWD1XfYssCJ459-gbANSysi6Il4sHHAK5VUYwo3eOV-QQMIlXFDdE5lxSRR5NlyuuWoTyUKlx-S5fq_2kXGGVPeQAaTYhZ-FLc9IHazWTd2CE4kpiJkgMwOfTUAaJ9zaLDRm6sCd948gWJlcA4ZQNvhDn6q3eE5YONFi6shDP0cAdR0geQB7C4q2GFfGBtNi1Awb6pzZjQEYIWF9Rs7BE-Q4HqgQlEzKjssIQJihsPbu7HOsadDMbX66E6wMy8E7YOkcHrKpUFD9RWPwUmhkB2VBT66OiOIJ_n0F1ogKN9X0o8EqK9MwanyjDB7b44XKsGE4kM2jzkqqtBRaQdyHkqEnUGhunbluwVWVJYaxQuqnTfrWb3uFyVlyvHcJ0v7qug-cbhJ47Gge-phClVNV-vgE0MjHCJdvt47QOVGnZ1goHPtZFgKL80z3RDd6l-PneCVCMPSZYIYJvIPABFgQ4p264V9ajadykLMEsVIFqBXm6I7zk1z-70SZ0vyYyB-6R6H7PSMe3gtZ6S7I_wRloEB_Vkw10ODQ
    # OPT
    brokerK8sCA: >-
      LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURNakNDQWhxZ0F3SUJBZ0lJSGVzVTdzRzg4ZGd3RFFZSktvWklodmNOQVFFTEJRQXdOekVTTUJBR0ExVUUKQ3hNSmIzQmxibk5vYVdaME1TRXdId1lEVlFRREV4aHJkV0psTFdGd2FYTmxjblpsY2kxc1lpMXphV2R1WlhJdwpIaGNOTWpNd01URTNNRGcwTXpVMFdoY05Nek13TVRFME1EZzBNelUwV2pBM01SSXdFQVlEVlFRTEV3bHZjR1Z1CmMyaHBablF4SVRBZkJnTlZCQU1UR0d0MVltVXRZWEJwYzJWeWRtVnlMV3hpTFhOcFoyNWxjakNDQVNJd0RRWUoKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBSytXalJPVXNaanowV2hsZW4xWEFRUUtNZlM3N0xjRgpUb2VOWGF3QWYrS3hhOStZa2NzaVBITStxN1NuYUY0TFBSZWhEYkM5b3N3U0JQSWM1MUc4VUNrNjNwdXNXek9MCkJvZWRpOWxHSS8wWlJJMkZxVjlzOXd4MEZsVmw0a1lmaFJ6R0hWV3ZrbGxVWlF5UkJNS0o2ZG00eGczMG9UZE8Kdkg3cXVUVzdwR2FOQ2s4d1l3alhzUlo1UUNxQ3BMWkhtNWxkd3psMDVHQllCMCsrYWdtU0hEaStTRTYyNHFoSQpkdkR5V05rWlkrQjV6dytIMEFZbVJRdVowcXNITjR5WjVzN2h5Q1dWdE5PZVk1akp6alJTN2hjRnlBdkVad1psCjNESTlTcWVFNVg0SjZESmJXMGRLRHpqaGNOSGlJcW9zNlROak9DTFoxem83czllclIyckNXQUVDQXdFQUFhTkMKTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3SFFZRFZSME9CQllFRkNrMQpPMFlWTDA3OUZpL3ZpWGNHRWlSckovdWlNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUFBWUprU3Y4VFpxTndKCm5HZWdraGhON0hKLzNGMmRoTS9ucEZFWjJHakIvcXNDL1R3ODl0Z2lOY1FWQlAvQjQzemo1RStvYzJ0ZVl1N0gKMDZnZHZ0eGVvdUxVZ0FRZDRCOVpTOGIwZm5kSkVVNVdUeHRZQnpZVXdYKzhXMkVFaW5PamVVN2pWeXVKM0dQcgo4WkY0cWRnTjI5RmVNaTdSQW15YUpjcE95MHhUcG5xSlplbVF2cndER1BrM3hZTS94alo0MzBRdXBSYll5TC93Cks3dHMzVnpzbjJkc3d1ajZ6QlBMaU52cjBWTUlpMVl5VS9NTmMzUkhzQWczS3RmbzRuRWw2aGJwaWs4VHo3MWIKMEF5cHN4U0lMYjFkZ3JZUUNreVRkWCs4OEVVNlBWdGRpRGdNVnlvR1FFVG0xc0RSa2JTZVpKNy9ubExkZ255OApKQ2xPQkJYRQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlEUURDQ0FpaWdBd0lCQWdJSVZjdXFpMWVkeFdNd0RRWUpLb1pJaHZjTkFRRUxCUUF3UGpFU01CQUdBMVVFCkN4TUpiM0JsYm5Ob2FXWjBNU2d3SmdZRFZRUURFeDlyZFdKbExXRndhWE5sY25abGNpMXNiMk5oYkdodmMzUXQKYzJsbmJtVnlNQjRYRFRJek1ERXhOekE0TkRNMU0xb1hEVE16TURFeE5EQTRORE0xTTFvd1BqRVNNQkFHQTFVRQpDeE1KYjNCbGJuTm9hV1owTVNnd0pnWURWUVFERXg5cmRXSmxMV0Z3YVhObGNuWmxjaTFzYjJOaGJHaHZjM1F0CmMybG5ibVZ5TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE4Q2I1Tm1XeUExdXAKL3Faamx2WVNYd2gyaWwyOUcvMUJ4U2hiWXRhRkNKTG1FUll5Tm5QOTN5akhlYTNUZ3pNaE1HQUNhRDVOd1ovTgpFSGtWL2hZUmdDSFp5dksvMzZvc3psNVNEaHJPakxGODlmUEN4bC9vTDVhME9Sb0hIbXFyWTF0cFJudFE1eUVHClduclpsa28zT2JUWjFjMTNEd3NmL21FYmVVbk42SkpXOHdXZFlTL2tqSkUxdDNqNDJ3WVViNG8yRVM0UU9QNXMKVkF6bVVxai9qcHZIK3Jqd0pXN0JqRC9qZVdXT3RkY2lza3Fsc2ZORjd6VzVLbnNFK2RFS1c1OUk4SkZHUDBScgpnTjh3VUNzS0dITTcydlF0cXJDVmZqaUpXWlExU0ZuUk1iVnBDc29rRW52NHY5cElldVl3cGFLd1YwOXpMSXZ0CkloL1NuUFc1d1FJREFRQUJvMEl3UURBT0JnTlZIUThCQWY4RUJBTUNBcVF3RHdZRFZSMFRBUUgvQkFVd0F3RUIKL3pBZEJnTlZIUTRFRmdRVS8xdFhoeEFqbkxoMTNoNmhlM095ek1ZdjduUXdEUVlKS29aSWh2Y05BUUVMQlFBRApnZ0VCQUZ1dEZBYi92RHJCemtrbEVkRTNlZ29ta25NWUQ4ZWhtYnNhZ3BWQ3hiRFNlYThkK0FtS0doR2FwYWhlCjNjZTlzS3kvT0tuUy9zWFNJR0xzV211T3ZBM2xkY0lvYldoOXhxaFM0ajlFQXNyeDdqbG5ZRy9meU5PSGJLazcKbXorUGNRRm9oOGNaMDZ0M2F1VU9TK2JWbW5TOHFQbDNySzkyUzlmVVd1N2lqRXMwK3JhOG9EUGp5QzFvbG9adwpKSWlCQ2Q1dW9CeTUxcEhLa3MyUTVzdnlZcldlZkZIdDdtUmt5endDUVZEcnJZWEpsaUtpWEEwMTk0dmU2VzZICllSNkFqNmZoMnN5TEtKSSs4dVBNL2cwR0lla3VuTjlEZDArY3ZGYUxoU2xmNVNwdzJSZmZRdThWQ2RsVVlmUGMKaUJOdURLVkNHQjZjQ005QjkzcHFIWWsvWjBnPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlEVERDQ0FqU2dBd0lCQWdJSWZBL2VaSmt5MnV3d0RRWUpLb1pJaHZjTkFRRUxCUUF3UkRFU01CQUdBMVVFCkN4TUpiM0JsYm5Ob2FXWjBNUzR3TEFZRFZRUURFeVZyZFdKbExXRndhWE5sY25abGNpMXpaWEoyYVdObExXNWwKZEhkdmNtc3RjMmxuYm1WeU1CNFhEVEl6TURFeE56QTRORE0xTkZvWERUTXpNREV4TkRBNE5ETTFORm93UkRFUwpNQkFHQTFVRUN4TUpiM0JsYm5Ob2FXWjBNUzR3TEFZRFZRUURFeVZyZFdKbExXRndhWE5sY25abGNpMXpaWEoyCmFXTmxMVzVsZEhkdmNtc3RjMmxuYm1WeU1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0MKQVFFQTNFT2YxRUxIdWRSa2JwZktFUzZENW5Gak5zL2NDdE9lT0Q3WVNLWUtHRDNTL0FPaTdHbkZhMCtUbzhseAo5dWRPamUwdExiQlFMOVVVYnExdkppb3libDAwUFJVa3dGNjQwbTRad3krVWFac1c3UHRFdVRkMDBsaWxLTEo0CkN3RHBjS3NjSy9xQjRXc0pJOENudXFlc1I3K0tnNjRPb2Y5QW9IUFJsWmxRRk9kTEQ2WDc0dE9TbmFRQXdQSnEKcnVYNUhDY04wdlN2SUJoSlZodTNzQVBodzB0bnVod05YNGZMQ09ZMTVIbFVUQjBJZEE3Q2Z2NE1ueXlibjVMcApTY25PLzJrcjM1aGV0MFFPNGJNRk1YdGVvc3d2VmNqZU1GOUhyV2g4dmtEamRSd2wwM3dMaDZtcS94L2VUL0ZxClB5UzlobGZNUUNJQ25hREpzTUlOaVZDUHFRSURBUUFCbzBJd1FEQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0R3WUQKVlIwVEFRSC9CQVV3QXdFQi96QWRCZ05WSFE0RUZnUVV6N2tlU0xrQXhmYlZKQ0puR3Q2WG5JTDRjWGN3RFFZSgpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFFY1ZMZEk0SExLcnVNTWJrK3BleEQwZGVSZjl1TE8rYXNjWkVTVUZCRjRYCktxdXlsR2VhNlhSWmJYdTEzU2NTbm9ZQXhmQVV5b3BKMGtlVks1VlNwamsrRVlIeGpVRjVMV3dsellvbS96N00KUnFtQVJSYWRBL21pTmVSNjBYZUhVb0ErYys5bkFYNTR4TWJGV0w0ZHJLWW5nNTVTUml1Y3FSNlkyYWkvL3dhVApydHhuSDZieWdwNG9GS1doSCtkZ244RXpOUVFsVGMvOVFoMXdoKzUwZnh6aStNOUppNm5ySDhTL3FqTXRTVFN1CnB0bzBmZXFZc0cyQ0ZObXRoRmJkMEkzNFZoTjltMjFhY2h5elFlOGhLWllzYXFSdTlUVWZ4YjdRVm0zcXJkbXkKQVV2bEN5anc0eExpOTlqc2VHNDlmRU8vMDA3VHFuY2xndXVUUVFyNi9NRT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQotLS0tLUJFR0lOIENFUlRJRklDQVRFLS0tLS0KTUlJRGx6Q0NBbitnQXdJQkFnSUlPOFRPQks0TEtJNHdEUVlKS29aSWh2Y05BUUVMQlFBd1dURlhNRlVHQTFVRQpBd3hPYjNCbGJuTm9hV1owTFd0MVltVXRZWEJwYzJWeWRtVnlMVzl3WlhKaGRHOXlYMnh2WTJGc2FHOXpkQzF5ClpXTnZkbVZ5ZVMxelpYSjJhVzVuTFhOcFoyNWxja0F4Tmpjek9UVXdNVEF3TUI0WERUSXpNREV4TnpFd01EZ3gKT1ZvWERUTXpNREV4TkRFd01EZ3lNRm93V1RGWE1GVUdBMVVFQXd4T2IzQmxibk5vYVdaMExXdDFZbVV0WVhCcApjMlZ5ZG1WeUxXOXdaWEpoZEc5eVgyeHZZMkZzYUc5emRDMXlaV052ZG1WeWVTMXpaWEoyYVc1bkxYTnBaMjVsCmNrQXhOamN6T1RVd01UQXdNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXdZeUsKYTB0dmIvMEZBd1o1V1JyOHBScFhic1kwMFd6bFJsNThXOTR1QXo0bEhhUm5yWjBoa2NBQ3ZwZzZYWFhuZDBaTQpmeXJLODVpNm1yVTNzbWF3Mlpma05wNUxLOTRJN25KSG9nR1ZsUEROVkpKQUJYWHU4bHBSZ2UrZGNabmc5WnVrCnl3NnZpVkhUVE9EbXJyQzR4WU51UURLWStvanJBMlU3aXM1aGdzMDB3bjc0a1JGQ2Q0NWFPZnAwaFB6RTVLOTMKdHJ4RDRIZzkrcjI2UnVvUy96K21rczVqTUhuUS85NExEc3VSYVZoV25JY3V0TUV0aDJ3anNvZTdCdHE3M2NBOAp5SlhWQysyNlRUSFgzajZjNXBHVFJoeHpmKzhwcmpueTRoTDVrWDFmQjQwWUZSRDdOUm9Oa2JHQnNjWWZyajFsCi9zUng1SU1JdmVGN0syM1p6UUlEQVFBQm8yTXdZVEFPQmdOVkhROEJBZjhFQkFNQ0FxUXdEd1lEVlIwVEFRSC8KQkFVd0F3RUIvekFkQmdOVkhRNEVGZ1FVeVJRaVF1UE04VG4zWmZkai9LYWFZS1Rhd0hjd0h3WURWUjBqQkJndwpGb0FVeVJRaVF1UE04VG4zWmZkai9LYWFZS1Rhd0hjd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFNQ0Rnb25SCksrZzY0ZHhVQ3hkdVBPK3l6ZDFZcFl6ZmJpQkhSVVQ0WTNnOVNsNmNKVWkxMklGWWRTSGdyTVI1WlJnbENuSVAKK3lieU0yWk1oVVlTZnhyZVJaV0hOaGs4TjFLZy9yOGV2K0xXaHkwTVdiRUxXalBpMmxTemttb2lmcWZLaXBiVgo4UmYrRUR2MVdSUlhrVFd1NldDN0RVbXBZT1ExeGNVaFV2L2ZhMXRITERGSjVYajJUQjVQT2V6NEdCWGFrU1ZuCkNwTmlDZVdhY1pVaFlmU3F1RGpJQkhsaFlzWENqakk0cGdXNmZPV1R0ZjhRV0tZNEE2bXZwZnhjaEFtZjRUUVQKeUNQaGU1RU03QTg0eFMwbFpzOVZzdDF5aEFYclJ1WDdZS3NsREVSZXYvdmgrZ2RmRnFEemJGWUpGZXlKZE0xNgpoRkdndVRuL1NuaEs1TlE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZRekNDQkN1Z0F3SUJBZ0lVUnZTdUVjQjBmcWJPQzgyQnY2YU9zNXBlbS9zd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1R6RVZNQk1HQTFVRUF3d01UMEZDSUZCR1VFRkpJRU5CTVNrd0p3WURWUVFLRENCUGNtRnVaMlVnUVhCdwpiR2xqWVhScGIyNXpJR1p2Y2lCQ2RYTnBibVZ6Y3pFTE1Ba0dBMVVFQmhNQ1JsSXdIaGNOTWpJeE1URTFNVFkwCk5EQTVXaGNOTWpVd01qRTNNVFkwTkRBNVdqQ0JyekVMTUFrR0ExVUVCaE1DUmxJeEREQUtCZ05WQkFnTUEwbEUKUmpFT01Bd0dBMVVFQnd3RlVHRnlhWE14S1RBbkJnTlZCQW9NSUU5eVlXNW5aU0JCY0hCc2FXTmhkR2x2Ym5NZwpabTl5SUVKMWMybHVaWE56TVF3d0NnWURWUVFMREFOUVFVa3hJakFnQmdOVkJBTU1HU291WVhCd2N5NXdZV2x3CmNtOWtiaTQyTWpCdWJTNXVaWFF4SlRBakJna3Foa2lHOXcwQkNRRVdGbVJ2WXkxd1lYa3ViMkZpUUc5eVlXNW4KWlM1amIyMHdnZ0lpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDQVFDb2J3R1gyS3BZaUM3WQpqSVlPQnZpdSs3alVwSWs0UDVGWGp4UGxrbisvWWhUY3RBV3NITjJwa1QrS0pta3Q4bzkyN1laKzR3LytrWDY3CldDRVZxVEFXRlJEbGVweElDRmVTVTVkL1gvc24yQUREa2ppbEVwcXJMa1pUdVNGdHgydStrQ1NWMzh0cmZZMHIKWTErQktvWGVINTJ2ZXhuK3RpdFZ2S0YwcU1GbmVIK2dLVm5CUzRCNHd1ODVIWWtIOWdBdDMxdG1wdzdMbGVWKwpIWERvU0dLbCtPRStLejU4dHl2MVg4ZXovSld5S1V0VzNpUTlvNUs0ektwMXFIaTZiWU85NGZuUjJFcFRIMTZsCm1YQk1VWEtHVHNlZGdJYnFaNjBFZHNLZTdWdHJia0dleWM5ay9JNmRyREtzQzZaelh3RU5qYzJSajM3elRac3AKbXg5WGxYTVJuSXd6b2p0MWhpWEw0WkMwM0dQT3ZNVjAyZStpQ1ZqYkUvcEJDYWRTc2c4Vkd0NjRPcG1EU1BqUQp3N1lQdHB5aVdmOFMzS0FIV0M4ZmdZRFhIUHJ5WG01NXF6YWFUbk9MRXZxTzFrVnpYRytWaHBLSUcycFM5R3NtCmtnS3ZMZGw4UHJLaVAyREt6TnEvUXJQaXhIM1FHOHRMb0Y3ZWpndkpnbzkraFpLSjBMRzVneWJWYnY2Z205WWUKL3UwVWNxS1JpNzhySXFiMVI2VWE3aDVaejhGTFc3UyswTldKSlB6YnlpTFo0REVBZGdWSDE4N0NjbktJdUVHdApJNkhqWjR4M09hajByS09GTkh5RXFBNHJaWVJTWDArNnJMMytDdWdxaHNCMi80RnY2Z1Jjb05KZkk2c25qOTdxClM3NWNVUmoyVUNEVUExWmdGaWZGQjJXRE9QRDVwUUlEQVFBQm80RzFNSUd5TUQwR0ExVWRFUVEyTURTQ0YyRncKY0hNdWNHRnBjSEp2Wkc0dU5qSXdibTB1Ym1WMGdoa3FMbUZ3Y0hNdWNHRnBjSEp2Wkc0dU5qSXdibTB1Ym1WMApNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVU2U0QyU1pWTDIxeTY3UnhWUHdVNGRnK1pvU3N3CkV3WURWUjBsQkF3d0NnWUlLd1lCQlFVSEF3RXdIUVlEVlIwT0JCWUVGS2UxMlNFeVVTWS9QeGY1ZG1NWk5OTVMKWHllMU1BNEdBMVVkRHdFQi93UUVBd0lGNERBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUJNd3ByOFoxRmV1cwpIekdacEtrL0svMEJTZlB5UUNjbFFxeXNMRjNzMHRLWDh6UVR0dVFYRkQ1a1cxT0E2enh2dXBMbWRCTG1KWnJKClE1SXRpUWJ6ZTg0NUNDbFc5MHVxaHZ0UUpkeWJSVGFkZ1k0NVQ3WnJpTGZQRGE1VlY0MTdTTzJCY2lTY2xVTUUKSjJkVkdMYUhZZHNuQktqb29NRlJ4OGtydHg2ZElnejlqcWh0aGFZMlZxQ1ZROGVsdWhQS3N2T0pMeWwvMmhXTgpSWVYzVm4rYnVZNzZmbDZvNmtNYUdaS2M4WlVoOUJqSzB0clJXYktNSHJiMS9PSHdCVzQ3ZjNlaHRjVU9JNit6CnJoSWNtSXgxQkdCdzQ2ejgzZ3lna0V6WDIyTEZteXUrbzNHa2xWMUlDYmtqTytwMlJFYnJjdTlLZWlDeEcyd2UKU1VJSFJvdEx1Zz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    # OPT
    brokerK8sInsecure: true
    brokerK8sRemoteNamespace: submariner-k8s-broker
    # OPT
    brokerK8sSecret: broker-secret-bl72j
    # OPT
    cableDriver: libreswan
    ceIPSecDebug: false
    # OPT
    ceIPSecForceUDPEncaps:
    # OPT
    ceIPSecIKEPort: 500
    # OPT
    ceIPSecNATTPort: 4500
    # OPT
    ceIPSecPSK: Kh/UMBVF9qBJNijheU14FCnaCRkfpVRwxWdhvXnXDjHRkdi6sFX67sJad3wd3BsQ
    # OPT
    ceIPSecPSKSecret: submariner-ipsec-psk
    # OPT
    ceIPSecPreferredServer:
    clusterCIDR:
    clusterID: submarinerche
    # OPT
    colorCodes:
    # OPT
    connectionHealthCheck:
      enabled: true
      intervalSeconds: 1
      maxPacketLossCount: 5
    # OPT
    coreDNSCustomConfig:
      configMapName:
      namespace:
    # OPT
    customDomains:
    debug: false
    # OPT
    globalCIDR: 242.27.0.0/24
    # OPT
    imageOverrides:
    # OPT
    loadBalancerEnabled:
    namespace: submariner-operator
    natEnabled: false
    # OPT
    repository: quay.io/submariner
    serviceCIDR:
    # OPT
    serviceDiscoveryEnabled: true
*/}}
{{- define "sharedlibraries.submariner_submariner" -}}
  {{/*
  ######################################
  Validation GENERAL
  ######################################
  */}}
  {{/* CHECK $.Values.submariner.submariner  */}}
  {{- if not $.Values.submariner }}
    {{- fail "submariner_submariner template loaded without submariner object" }}
  {{- end }}
  {{- if not $.Values.submariner.submariner }}
    {{- fail "submariner_submariner template loaded without submariner.submariner object" }}
  {{- end }}
  {{/*
  ######################################
  Prepare list to push other information
  ######################################
  */}}
  {{- $avoidKeys := (list "name" "namespace" "additionalLabel" "additionalAnnotations" "syncWave" "broker" "brokerK8sApiServer" "brokerK8sRemoteNamespace" "ceIPSecDebug" "clusterCIDR" "clusterID" "debug" "natEnabled" "serviceCIDR" ) }}
  {{- range $submarinerSubmariner := $.Values.submariner.submariner }}
    {{/* DEBUG include "sharedlibraries.dump" $submarinerSubmariner */}}
    {{/*
    ######################################
    Validation Mandatory Variables submarinerSubmariner
    ######################################
    */}}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.name
    ######################################
    */}}
    {{- if not $submarinerSubmariner.name }}
      {{- fail "no name set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.namespace
    ######################################
    */}}
    {{- if not $submarinerSubmariner.namespace }}
      {{- fail "no namespace set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $submarinerSubmariner.additionalLabels
    ######################################
    */}}
    {{- if and ($submarinerSubmariner.additionalLabels) (not (kindIs "map" $submarinerSubmariner.additionalLabels)) }}
      {{- fail (printf "additionalLabels is not a DICT inside submariner.submariner object but type is :%s" (kindOf $submarinerSubmariner.additionalLabels)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK KIND $submarinerSubmariner.additionalAnnotations
    ######################################
    */}}
    {{- if and ($submarinerSubmariner.additionalAnnotations) (not (kindIs "map" $submarinerSubmariner.additionalAnnotations)) }}
      {{- fail (printf "additionalAnnotations is not a DICT inside submariner.submariner object but type is :%s" (kindOf $submarinerSubmariner.additionalAnnotations)) }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.broker
    ######################################
    */}}
    {{- if not $submarinerSubmariner.broker }}
      {{- fail "no broker set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.brokerK8sApiServer
    ######################################
    */}}
    {{- if not $submarinerSubmariner.brokerK8sApiServer }}
      {{- fail "no brokerK8sApiServer set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.brokerK8sRemoteNamespace
    ######################################
    */}}
    {{- if not $submarinerSubmariner.brokerK8sRemoteNamespace }}
      {{- fail "no brokerK8sRemoteNamespace set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK BOOL $submarinerSubmariner.ceIPSecDebug
    ######################################
    */}}
    {{- if not ( hasKey $submarinerSubmariner "ceIPSecDebug" ) }}
      {{- fail "no ceIPSecDebug set inside submariner.serviceDiscovery object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.clusterCIDR
    ######################################
    */}}
    {{- if not $submarinerSubmariner.clusterCIDR }}
      {{- fail "no clusterCIDR set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.clusterID
    ######################################
    */}}
    {{- if not $submarinerSubmariner.clusterID }}
      {{- fail "no clusterID set inside submariner.submariner object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.debug
    ######################################
    */}}
    {{- if not ( hasKey $submarinerSubmariner "debug" ) }}
      {{- fail "no debug set inside submariner.serviceDiscovery object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK BOOL $submarinerSubmariner.natEnabled
    ######################################
    */}}
    {{- if not ( hasKey $submarinerSubmariner "natEnabled" ) }}
      {{- fail "no natEnabled set inside submariner.serviceDiscovery object" }}
    {{- end }}
    {{/*
    ######################################
    CHECK $submarinerSubmariner.serviceCIDR
    ######################################
    */}}
    {{- if not $submarinerSubmariner.serviceCIDR }}
      {{- fail "no serviceCIDR set inside submariner.submariner object" }}
    {{- end }}
---
apiVersion: submariner.io/v1alpha1
kind: Submariner
metadata:
  name: {{ $submarinerSubmariner.name }}
  namespace: {{ $submarinerSubmariner.namespace }}
  labels:
    release: {{ $.Release.Name }}
    heritage: {{ $.Release.Service }}
    {{- if $submarinerSubmariner.additionalLabels }}
{{ toYaml $submarinerSubmariner.additionalLabels | indent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ default "04" $submarinerSubmariner.syncWave | squote  }}
    argocd.argoproj.io/managed: "true"
    argocd.argoproj.io/application-name: {{ $.Release.Name }}
    {{- if $submarinerSubmariner.additionalAnnotations }}
{{ toYaml $submarinerSubmariner.additionalAnnotations | indent 4 }}
    {{- end }}
spec:
  namespace: {{ $submarinerSubmariner.namespace }}
  broker: {{ $submarinerSubmariner.broker }}
  brokerK8sApiServer: {{ $submarinerSubmariner.brokerK8sApiServer }}
  brokerK8sRemoteNamespace: {{ $submarinerSubmariner.brokerK8sRemoteNamespace }}
    {{- if hasKey $submarinerSubmariner "ceIPSecDebug" }}
      {{- if $submarinerSubmariner.ceIPSecDebug }}
  ceIPSecDebug: true
      {{- else }}
  ceIPSecDebug: false
      {{- end }}
    {{- end }}
  clusterCIDR: {{ $submarinerSubmariner.clusterCIDR }}
  serviceCIDR: {{ $submarinerSubmariner.serviceCIDR }}
  clusterID: {{ $submarinerSubmariner.clusterID }}
    {{- if hasKey $submarinerSubmariner "debug" }}
      {{- if $submarinerSubmariner.debug }}
  debug: true
      {{- else }}
  debug: false
      {{- end }}
    {{- end }}
    {{- if hasKey $submarinerSubmariner "natEnabled" }}
      {{- if $submarinerSubmariner.natEnabled }}
  natEnabled: true
      {{- else }}
  natEnabled: false
      {{- end }}
    {{- end }}
    {{- $parameter := dict }}
    {{- $_ := set $parameter "fromDict" $submarinerSubmariner }}
    {{- $_ := set $parameter "avoidList" $avoidKeys }}
    {{- $submarinerSubmarinerAdditionnalInfos := fromYaml ( include "sharedlibraries.removeListOfKeysFromDict" $parameter ) }}
    {{- if $submarinerSubmarinerAdditionnalInfos }}
{{ toYaml $submarinerSubmarinerAdditionnalInfos | indent 2 }}
    {{- end }}
...
  {{/* END RANGE */}}
  {{- end }}
{{/* END DEFINE */}}
{{- end -}}
