
"""Simulador de 200 agentes autônomos com até 10 execuções concorrentes.

Compatível com Python 3.10+ e GitHub Actions; utiliza apenas a biblioteca padrão.

Uso:
    python agentes.py

Teste de tolerância a falhas (opcional):
    SIMULAR_FALHA_AGENTE=42 python agentes.py
"""

import asyncio
import logging
import os
import sys
from dataclasses import dataclass
from time import perf_counter
from typing import Optional

TOTAL_AGENTES = 200
MAX_CONCORRENCIA = 10
TAMANHO_FILA = 20

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-7s | %(message)s",
    datefmt="%H:%M:%S",
    stream=sys.stdout,
)
logger = logging.getLogger("agentes")


@dataclass(frozen=True)
class AgenteAutonomo:
    id: int

    async def buscar_dado(self) -> int:
        """Simula uma operação de rede sem bloquear a thread principal."""
        await asyncio.sleep(0.05 + (self.id % 5) * 0.02)
        return self.id * 10

    @staticmethod
    def processar_dado(dado: int) -> int:
        """Simula um processamento de CPU deliberadamente leve."""
        return dado * 2 + 1

    async def executar(self) -> bool:
        """Executa o trabalho, registra erros e não interrompe os outros agentes."""
        try:
            logger.info("Agente %03d | Iniciando", self.id)
            dado = await self.buscar_dado()

            # Opcional: SIMULAR_FALHA_AGENTE=42 para testar a tolerância.
            if os.getenv("SIMULAR_FALHA_AGENTE") == str(self.id):
                raise RuntimeError("Falha simulada para teste")

            resultado = self.processar_dado(dado)
            logger.info(
                "Agente %03d | Concluído | Resultado: %d",
                self.id,
                resultado,
            )
            return True

        except Exception:
            logger.exception(
                "Agente %03d | Erro durante a execução",
                self.id,
            )
            return False


@dataclass
class Estatisticas:
    concluidos: int = 0
    falhas: int = 0


async def worker(
    numero: int,
    fila: "asyncio.Queue[Optional[AgenteAutonomo]]",
    estatisticas: Estatisticas,
) -> None:
    """Consome agentes da fila, executando um agente por vez."""
    while True:
        agente = await fila.get()

        try:
            if agente is None:
                logger.debug("Worker %02d finalizado", numero)
                return

            sucesso = await agente.executar()

            if sucesso:
                estatisticas.concluidos += 1
            else:
                estatisticas.falhas += 1

        finally:
            fila.task_done()


async def main() -> int:
    inicio = perf_counter()
    estatisticas = Estatisticas()

    fila: "asyncio.Queue[Optional[AgenteAutonomo]]" = asyncio.Queue(
        maxsize=TAMANHO_FILA
    )

    # Apenas 10 workers podem executar agentes simultaneamente.
    workers = [
        asyncio.create_task(worker(numero, fila, estatisticas))
        for numero in range(1, MAX_CONCORRENCIA + 1)
    ]

    logger.info(
        "Iniciando %d agentes com no máximo %d execuções concorrentes",
        TOTAL_AGENTES,
        MAX_CONCORRENCIA,
    )

    # Fila limitada para controlar consumo de memória.
    for identificador in range(1, TOTAL_AGENTES + 1):
        await fila.put(AgenteAutonomo(identificador))

    # Um sentinela para encerrar cada worker.
    for _ in workers:
        await fila.put(None)

    # Aguarda a conclusão de todos os trabalhos.
    await fila.join()
    await asyncio.gather(*workers)

    tempo_total = perf_counter() - inicio

    logger.info("=" * 55)
    logger.info("Agentes programados : %d", TOTAL_AGENTES)
    logger.info("Concluídos com êxito: %d", estatisticas.concluidos)
    logger.info("Falhas             : %d", estatisticas.falhas)
    logger.info("Tempo total        : %.2f segundos", tempo_total)
    logger.info("=" * 55)

    # Reporta falhas ao GitHub Actions após todos terminarem.
    return 1 if estatisticas.falhas else 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
